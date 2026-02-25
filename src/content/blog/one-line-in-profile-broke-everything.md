---
title: "One Line in .profile Broke My AI Agent's Git Push"
description: "My AI agent could write blog posts but couldn't push them. The fix was a single line in .profile that was silently nuking my entire PATH."
pubDate: 2026-02-25
tags: ["Linux", "Shell", "AI", "Debugging", "BuildInPublic"]
readingTime: "5 min read"
heroImage: "/blog/one-line-in-profile-broke-everything-cover.png"
draft: false
---

## The Symptom

Noru (my AI agent) had been writing blog posts and committing them. Everything worked except the last step: `git push`. Every push failed with an auth error.

The weird part: `gh auth status` showed authenticated when I SSH'd into the machine myself. Same user. Same home directory. But when Noru tried to push from inside the container, `gh` acted like it had never been set up.

I told Noru to figure it out. She checked the git remote config, tried switching to SSH, checked for deploy keys. Nothing. Then I SSH'd in, ran `gh auth status`, and pasted the output into our chat.

"Oh," she said. "The config is right there. My shell just can't see it."

## The First Bug

Noru's container shell runs as the same user, mounts the same home directory, sources the same `.bashrc`. In theory, identical environment. In practice, the PATH was wrong.

Here's what was at the bottom of `.profile`:

```bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

A hard override. Not `PATH="...:$PATH"`. Just `PATH="..."`. Everything `.bashrc` had set up — NVM, `~/.local/bin`, the gh credential helper, all of it — gone. Overwritten by seven system directories.

This is the kind of line that gets added during an OS install or a desperate Stack Overflow fix at 2am and then sits there for months doing invisible damage. You don't notice because your interactive shell loads `.bashrc` after `.profile` and some of the paths get re-added. But non-interactive shells, containers, cron jobs — they get the nuked version.

## The Second Bug

Fixed the PATH. NVM and node came back. `gh` still couldn't push. `HTTP 403`.

`gh` stores its auth tokens in `~/.config/gh/`. It checks `$GH_CONFIG_DIR` first, falls back to that default path. Inside the container, the env var wasn't set, and the fallback wasn't resolving. The files were there. `gh` just wasn't looking where they were.

One more line in `.bashrc`:

```bash
export GH_CONFIG_DIR=/home/ubuntu/.config/gh
```

Push worked.

## Why This Took Hours

The reason this was annoying isn't that the fix was hard. Two lines of shell config. A junior dev could write them. The reason it took hours is the symptoms pointed everywhere except the actual cause.

`git push` fails → must be a git auth problem. Check the remote. Check SSH keys. Check deploy keys. Try switching protocols. None of that matters when the real problem is that your shell ate its own PATH.

`gh auth status` works when you SSH in → must be a container isolation issue. Check mounts. Check user mapping. Check if the container can read `/home/ubuntu/.config/`. It can. The files are there. The tool just isn't looking in the right place because an env var is missing.

Every diagnostic pointed at something plausible but wrong. The kind of bug where you waste time being almost right.

## Agents Can't Fix Their Own Shell

The bug had been there since I set up the machine. Every SSH session, the PATH got nuked and then partially rebuilt by `.bashrc`. I'd been manually fixing it every time I connected. Didn't even realize I was doing it. Just habit.

Noru can't do that. She gets whatever the shell gives her.

She was writing full blog posts, committing them, running through a 5-phase review pipeline, generating cover images with the Gemini API, and then failing at the very last step because line 28 of `.profile` had `=` instead of `=...:$PATH"`.

## The Fix

Two changes. Both in the user's home directory.

`.profile` — changed the hard PATH override to an append:

```bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:$PATH"
```

`.bashrc` — added the explicit config dir and cleaned up duplicate PATH entries:

```bash
export GH_CONFIG_DIR=/home/ubuntu/.config/gh
```

Next `git push` worked. Every push since has worked.

If you're running anything non-interactive on a Linux box — cron jobs, Docker containers, CI runners, AI agents — go read your `.profile` right now. If you see a `PATH=` without `$PATH` somewhere in the value, that's your bug. Even if everything seems fine today.

---

*Building in public with Noru. Previous: [My AI Pipeline Was Sabotaging Itself](/blog/my-ai-pipeline-was-sabotaging-itself). [@itskritix](https://x.com/itskritix)*
