---
title: "My Task Scheduler Was Running Everything Twice"
description: "A race condition in my poll-based task scheduler was firing every cron job twice. The fix was one line. Finding it took longer."
pubDate: 2026-03-15
tags: ["Node.js", "Debugging", "Automation", "BuildInPublic"]
readingTime: "6 min read"
draft: false
---

My AI agent posts social media carousels on a schedule. Three times a day, a cron job fires, the agent generates images, reviews them, and sends the results to WhatsApp. Clean system. Worked great.

Until I noticed every carousel was showing up twice.

## Same Task, Same Output, Two Minutes Apart

The logs told the story. A task scheduled for 1:00 PM was running at 1:00 PM _and_ again at 1:01 PM. Same prompt, same everything. The agent would generate five carousel slides, send them, then immediately generate five more and send those too.

My first thought was the cron expression was wrong. Maybe I'd accidentally scheduled it twice. Checked the database:

```sql
SELECT id, prompt, schedule_value, next_run
FROM scheduled_tasks
WHERE status = 'active';
```

One task. One cron expression. `0 13 * * *`. Once a day at 1 PM. Nothing weird.

## The Poll Loop

My scheduler is simple. Every 60 seconds, it polls the database for due tasks:

```typescript
export function getDueTasks(): ScheduledTask[] {
  const now = new Date().toISOString();
  return db.prepare(`
    SELECT * FROM scheduled_tasks
    WHERE status = 'active'
      AND next_run IS NOT NULL
      AND next_run <= ?
    ORDER BY next_run
  `).all(now) as ScheduledTask[];
}
```

When it finds one, it enqueues it. The queue has dedup logic:

```typescript
enqueueTask(groupJid: string, taskId: string, fn: () => Promise<void>): void {
  const state = this.getGroup(groupJid);

  // Prevent double-queuing of the same task
  if (state.pendingTasks.some((t) => t.id === taskId)) {
    logger.debug({ groupJid, taskId }, 'Task already queued, skipping');
    return;
  }

  // ... enqueue it
}
```

Looks fine. If the same task ID is already in the pending queue, skip it. Should prevent duplicates.

It doesn't.

## The Window

Here's what actually happens:

1. **1:00:00** — Poll fires. `getDueTasks()` returns the task because `next_run` (1:00 PM) <= now. Task gets enqueued.
2. **1:00:01** — Task starts executing. It's removed from `pendingTasks` and starts running. The AI agent spins up a container, generates images. This takes 4-5 minutes.
3. **1:01:00** — Poll fires again. `getDueTasks()` queries the database. The task's `next_run` is still `2026-03-14T13:00:00Z` because `next_run` only gets updated _after_ the task finishes. So the query returns it again.
4. The dedup check looks at `pendingTasks`. The task isn't pending anymore. It's running. The check passes.
5. Task gets enqueued a second time.

The race window is `execution_time - poll_interval`. My tasks take 4-5 minutes. The poll runs every 60 seconds. So there are 3-4 extra polls during execution, each one seeing the same stale `next_run` and re-queuing the task.

The dedup only checked if the task was queued. It didn't check if it was already running.

## Why This Pattern Is Everywhere

Search "cron job running twice" on GitHub. You'll find this exact bug in [node-cron](https://github.com/node-cron/node-cron/issues/353), [node-schedule](https://github.com/node-schedule/node-schedule/issues/263), [Spring Framework](https://github.com/spring-projects/spring-framework/issues/11525), [taskiq](https://github.com/taskiq-python/taskiq/issues/296), and even [Windows Task Scheduler](https://support.microsoft.com/en-us/topic/the-task-scheduler-service-runs-the-same-job-two-times-in-windows-server-2008-in-windows-vista-in-windows-7-or-in-windows-server-2008-r2-148b00e9-5e08-2e85-c2ab-df7c1088872f).

The pattern is always the same:
1. Poll for tasks where `due_time <= now`
2. Execute the task
3. Update `due_time` after execution completes
4. Next poll picks it up again because step 3 hasn't happened yet

If your tasks finish in under a second, you never notice. The poll doesn't fire fast enough to catch the stale state. But the moment you have a task that takes longer than your poll interval, boom. Doubles.

## The Fix

Update `next_run` before execution, not after.

```typescript
const loop = async () => {
  const dueTasks = getDueTasks();

  for (const task of dueTasks) {
    // Calculate and set next_run BEFORE executing
    let nextRun: string | null = null;
    if (task.schedule_type === 'cron') {
      const interval = CronExpressionParser.parse(task.schedule_value, {
        tz: TIMEZONE,
      });
      nextRun = interval.next().toISOString();
    } else if (task.schedule_type === 'interval') {
      nextRun = new Date(Date.now() + parseInt(task.schedule_value)).toISOString();
    }

    // Move next_run forward immediately
    if (nextRun) {
      db.prepare('UPDATE scheduled_tasks SET next_run = ? WHERE id = ?')
        .run(nextRun, task.id);
    }

    // Now execute
    deps.queue.enqueueTask(task.chat_jid, task.id, () => runTask(task, deps));
  }

  setTimeout(loop, SCHEDULER_POLL_INTERVAL);
};
```

One `UPDATE` before the enqueue. The next poll sees `next_run` as tomorrow and moves on. Task executes once.

## The Tradeoff

Optimistic scheduling has a failure mode. If the task crashes mid-execution, `next_run` already points to tomorrow. The failed run is gone. You don't get a retry.

For my use case, that's fine. A missed carousel is not a crisis. But if you're building a payment processor or a notification system, you probably want a different approach:

- **Status column**: Set `status = 'running'` before execution, filter it out in `getDueTasks()`. Reset to `active` when done. Add a cleanup job for stuck tasks.
- **Lock table**: Separate `task_locks` table with the task ID and a timestamp. Check the lock before enqueuing. Release after execution.
- **Redis lock**: `SET task:{id}:lock 1 EX 300 NX`. If the key exists, skip. Expires after 5 minutes as a safety net.

All of these are more code than the one-line fix. The status column is probably the right call for most production systems. The optimistic approach works when your tasks are idempotent or when occasional missed retries are acceptable.

## What I Didn't Try

I considered adding the running task's ID to the dedup check. Something like tracking `activeTasks` alongside `pendingTasks`. But that's a symptom fix. The real problem is the stale database state. Two places would need to agree on what's running. The database query should be the single source of truth, and it should reflect reality.

## The Broader Lesson

Poll-based schedulers are simple to build and simple to get wrong. The happy path works immediately. The edge cases show up weeks later when you realize your daily email digest has been sending twice since launch.

If you're building one, ask yourself: what happens when a task takes longer than my poll interval? If the answer is "it runs again," you have this bug. You just haven't noticed yet.

---

*Building [NanoClaw](https://github.com/AKShaw/nanoclaw) in public. Find me on [X @AKritix](https://x.com/AKritix).*
