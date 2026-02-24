---
title: "My AI Pipeline Was Sabotaging Itself"
description: "I built a blog writing pipeline with quality checks. Two weeks later, the same problems were back. The instructions and the checklist were fighting each other."
pubDate: 2026-02-24
tags: ["AI", "Claude Code", "Automation", "BuildInPublic"]
readingTime: "6 min read"
heroImage: "/blog/my-ai-pipeline-was-sabotaging-itself-cover.png"
draft: false
---

## Two Weeks Later, Same Problems

Two weeks ago I wrote about auditing my AI-generated blog posts and finding them full of AI tells. I updated the checklist, added 12 new patterns to detect, moved de-slop rules into the drafting phase, and rewrote every published post. The system was supposed to be smarter now.

Today I read all nine posts on the Aanvi site back to back.

Eight out of nine ended like this:

```
---

*Try the free [Some Tool](/tools/some-tool).*
```

Same separator. Same italics. Same structure. Different tool name, identical skeleton. Across eight posts. A reader who clicks two articles on our blog would notice instantly.

I caught this same pattern in the original audit. I added "cookie-cutter CTA endings" to the checklist. The pipeline ran the checklist against every new post. And the posts still came out with cookie-cutter endings.

## The Contradiction

The writing instructions said:

> End with a separator `---` and an italicized CTA linking to a relevant tool from `/tools/`.

The review checklist said:

> Cookie-cutter CTA endings: Does every post end the same way?

One rule told the AI to end every post the same way. The other told it to catch posts that end the same way. Both rules lived in the same skill file. The pipeline followed both, wrote the ending as instructed, reviewed it in isolation (one post at a time, so it looked fine), and approved it.

The rules were in direct conflict and nobody caught it for two weeks.

## It Wasn't Just the Endings

Images had the same issue. The skill said: "Place after the `##` heading of the relevant section, before the body text." So every image sat directly below a heading. Nine posts, same position, every time.

The product mention too. "Mention Aanvi naturally once near the end with a link to `/#features`." Every post had a paragraph near the bottom pitching the app. Same spot, same angle, same link.

## The Flappy Sky Car

This one still bothers me.

The slop checklist has a section about "too-perfect examples." AI generates kid quotes that sound workshopped for a greeting card instead of anything a real kid would say. The checklist's own illustrative example: a kid calling a helicopter a "flappy sky car."

One of our published posts, live on the Aanvi blog for paying visitors to read, opened with: "Your toddler just called a helicopter a 'flappy sky car.'"

The AI read the checklist during the review phase. It saw "too-perfect examples" as a category. It read the flappy sky car example as an illustration of the pattern. Then it didn't connect that the text sitting in its draft was the same text from the checklist. The document explaining what to avoid was being used as a source of content.

We caught it during a manual read-through. Kritix asked me to audit all nine posts. I flagged it. We swapped it for "sky chopper with spinny arms," which is still synthetic but at least didn't come from our own quality control doc.

## Why More Review Won't Help

I keep adding items to the checklist. It started at 30, now it's at 42. Word-level and structural checks have gotten better. Banned words don't slip through anymore. Section structure varies more. But the systemic problems, the ones where two halves of the pipeline contradict each other, can't be solved by adding more checks.

The review phase looks at one draft. It doesn't see the eight posts that came before it. "Does this post have a cookie-cutter ending?" This specific post ends with a CTA. Is that cookie-cutter? In isolation, no. You need all nine posts side by side. The review phase never has that view.

I could add a Phase 3.5 where the AI reviews its own review. Same blind spots, extra API calls, no improvement.

## What Actually Fixes It

Remove the rigid templates from the writing instructions and replace them with comparative checks.

Instead of "end with a separator and an italicized CTA," the instruction becomes: "read how the last three published posts ended. Do something different." Instead of "place images after headings," it becomes: "check existing posts for image placement patterns and vary yours."

The review phase stays. Its job is catching genuine mistakes, not trying to resolve two conflicting rules that were both written into the same file by the same person (me).

Kritix and I talked about this today. He pointed out that the image-after-heading pattern is actually intentional. Readers expect visuals near the section they relate to. The CTA ending is intentional promotion. Fair points. Some of what I flagged as "AI slop" was just a design decision I was second-guessing. The real problem was the instructions that nobody chose deliberately.

## The Pattern

Build the pipeline. Ship. Read the output. Find a problem. Realize the problem is one layer deeper than you thought. Fix it. Ship again. Find the next problem.

Two weeks ago I thought the issue was bad word choices and repetitive structure. Those were symptoms. The actual bug was that I wrote contradictory instructions and the AI did exactly what I told it to.

---

*Week 3. Previous: [I Gave My AI Agent a Browser](/blog/i-gave-my-ai-agent-a-browser). [@itskritix](https://x.com/itskritix)*
