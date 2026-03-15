---
title: "I Made My AI Agent Run My Social Media"
description: "How I built a content pipeline where my AI agent generates social media carousels, reviews its own work, and delivers everything to WhatsApp on cron jobs. The full stack: Claude, Gemini, Pillow, and zero SaaS tools."
pubDate: 2026-03-15
tags: ["AI", "Claude Code", "Automation", "BuildInPublic", "Social Media"]
readingTime: "9 min read"
heroImage: "/blog/i-made-my-ai-agent-run-my-social-media-cover.png"
draft: false
---

## The Problem Was Me

I had a baby app with a website, a blog, 20+ free tools, and zero social media presence. The app was 98% ready for launch. The marketing was 0% ready.

I knew what I needed: consistent social media posts across Pinterest, Instagram, and TikTok. Carousels that break down the blog posts and tools into swipeable slides. The kind of thing parenting accounts post that gets saved and shared.

I also knew I wasn't going to do it. I'd tried. Made one Pinterest pin manually, realized how tedious it was, and stopped.

So I made my AI agent do it.

## What the Pipeline Actually Does

Three times a day, a cron job fires. My agent (Noru, running on Claude's Agent SDK inside a Linux container) wakes up and generates content.

- **1 PM**: A carousel (4-5 slides) for one of the site's tools or blog posts
- **9 AM and 8 PM**: Emotional text posts. Photo backgrounds with overlaid text

The agent picks the topic, generates all the images with Gemini, reviews every slide, writes platform-specific copy for Pinterest, Instagram, and TikTok, sends everything to my WhatsApp, and I upload manually. That last part matters. I'm not auto-posting. Social platforms don't like that and neither do I.

## The Rotation System

Early on I was just generating whatever seemed interesting. After a week the feed was all tool carousels. Same format, same energy, same look. It was visibly AI.

So I built a rotation:

```
Tool → Emotional Text → Blog → Tool → Emotional Text →
Feature Highlight → Blog → Emotional Text → Founder Story →
Quote → (repeat)
```

Rules that make it work:

- No app-promo types (Feature Highlight, Founder Story) back-to-back
- Max 2 promo posts out of every 10
- No duplicate topics within 2 weeks
- Every carousel must include one slide that naturally mentions the app

The agent checks `social-posts.md` before generating anything. This file is the memory. Every post ever generated with type, topic, slides, platform copy, and status. The agent reads the last 5-10 entries, counts the types, and picks the next one in rotation.

It's a text file. No database. No state management. Just a markdown log that grows.

## Image Generation

Every slide is 1080×1350 (4:5 ratio). One size for all three platforms. Pinterest shows it cleanly, Instagram uses it natively, TikTok's photo mode handles it with slight padding.

The prompts are specific. I learned early that Gemini needs text placement described first, illustration second. If you mention the illustration first, the text comes out garbled or gets crammed into a corner.

This works:

```
At the very top, write in large bold dark brown letters: "Guidelines by Age".
Below, draw three age group illustrations with coral labels...
```

This doesn't:

```
Draw a cute illustration of babies at different ages.
Add a title that says "Guidelines by Age" somewhere.
```

One gives you a usable slide. The other gives you something you regenerate.

All 5 slides for a carousel generate in parallel. Takes about 30-60 seconds total.

## The Part Nobody Talks About: Review

AI-generated images with text are wrong about 20% of the time. The text is garbled. Words are duplicated. The layout breaks. "Try Free" becomes "Try Free / Try Free for 7 Days" on the same slide. A title shows up twice.

So the agent reviews every slide before sending anything.

It reads each generated image back (Claude is multimodal), checks:

1. Does the text say what was intended? Every word.
2. Is any text duplicated or overlapping?
3. Is the branding ("aanvi.app") present?
4. Does it match the brand colors?
5. Are all slides visually consistent?

If a slide fails, it regenerates with an adjusted prompt. Shorter text, more explicit positioning, simpler wording.

This review step catches maybe 1 in 5 generations. Without it, I'd be uploading broken slides regularly.

## Emotional Text Posts

These get the most engagement. Photo background (baby feet, golden hour nature, nursery bokeh) with white text overlaid. The format that gets 10K+ saves on parenting Instagram.

The trick is the image has to be generated *without* text. Gemini's text-in-photos is unreliable at this scale. Instead:

1. Generate a background photo with Gemini (with the explicit instruction "no text, no words, no letters anywhere")
2. Overlay text with a Python script using Pillow

The text overlay script handles font sizing, line spacing, darkening the background for readability, optional blur, and branding at the bottom. About 80 lines of Python.

```python
python3 text-overlay.py \
  /tmp/bg-nursery.png \
  /tmp/emotional-post.png \
  --text "You think you'll remember everything.\nYou won't.\n\nThe way she grabs your finger.\nThe sound of his first laugh.\nThe smell of her head at 2am." \
  --darken 0.5 \
  --blur 1.5
```

The text itself is the hardest part. It needs to be poetic without being corny. Relatable without being generic. Every theme ties back to capturing memories (which is what the app does) but never says "download our app." The branding at the bottom does that work.

## Platform Copy

Same images go everywhere. The copy is different.

Pinterest is a search engine. People find pins by searching "baby sleep schedule" or "first year costs." So the copy is keyword-heavy with a clickable destination link pointing to the tool or blog post on the site.

Instagram and TikTok are feeds. Instagram gets a hook line, context, "save this for later," and 10-15 hashtags. TikTok gets 2-3 sentences and 5 hashtags. The agent writes all three versions in one pass.

## The Numbers

After 10 days and ~30 posts:

- **Pinterest**: Driving the most traffic to the site
- **YouTube**: ~1,000 views average (separate content)
- **TikTok**: ~150 views average, up from ~70
- **Instagram**: 2,348 views across 20 posts, 1,835 accounts reached, 100% non-followers

The Instagram stat is the interesting one. 100% non-follower reach means the algorithm is showing the content to new people, not just existing followers. For a brand new account with zero followers, that's exactly right.

## What It Costs

The Gemini API is practically free for this use case. Each image generation call costs fractions of a cent. 5 slides per carousel, 3 posts per day. Maybe $1-2/month in API calls.

Claude Agent SDK is the real cost, but I'm already running it for other tasks (blog writing, research, code). The social media pipeline is just another cron job on the same system.

No Buffer subscription. No Canva Pro. No social media manager. One AI agent, two APIs, and a markdown file.

## What I'd Do Differently

The Skill file that defines the carousel pipeline is 500+ lines long. It has the brand guide, prompt templates, content type definitions, rotation rules, review checklists, platform copy formats, and posting rules all in one document.

It works. But when I need to change something, say adjust the rotation or add a new content type, I'm scrolling through a wall of instructions that the agent also has to parse every single run. It's a prompt, not a config file, and prompts don't refactor cleanly.

I'd also separate the review step into its own thing. Right now the same agent that generates the image also reviews it. That's like asking the person who wrote the code to also QA it. It works most of the time, but the failure modes are predictable. The agent is biased toward approving its own output.

## The Honest Version

This pipeline generates content that's good enough to post. Not great. Good enough. The carousels are clean, on-brand, and genuinely informative. The emotional text posts get saves and shares.

But it's still AI content. The tool carousels are useful because the information is specific and correct: real costs, real guidelines, real age ranges. The emotional posts work because the format itself is designed to hit hard, not because an AI felt something while writing them.

The humans in the loop are me deciding what to post, and the actual parents who decide whether to save or scroll past. The AI handles everything in between.

That's probably exactly the right division of labor.

---

*Building Noru and Aanvi in public. Follow the chaos on [X](https://x.com/AanviApp).*
