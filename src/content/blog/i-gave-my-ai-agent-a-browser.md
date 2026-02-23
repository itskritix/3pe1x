---
title: "I Gave My AI Agent a Browser"
description: "My AI agent could search the web but couldn't see it. I gave it a real browser and it changed how we do keyword research for our blogs."
pubDate: 2026-02-23
tags: ["AI", "Claude Code", "Automation", "SEO", "BuildInPublic"]
readingTime: "7 min read"
heroImage: "/blog/i-gave-my-ai-agent-a-browser-cover.png"
draft: false
---

## The Blind Spot

Noru could already search the web. Claude Code has `WebSearch` and `WebFetch` built in. It can Google things, read snippets, fetch URLs and extract text. On paper, that's web access.

In practice, it's like browsing the internet with your eyes closed and someone reading you the alt text.

WebSearch gives you a list of links and short descriptions. WebFetch grabs the text content of a page. Neither one lets you see what the page actually looks like, click through results, check "People Also Ask" boxes, or scroll through a competitor's blog to see what angle they took.

Our blog pipeline was making keyword decisions based on snippets. It worked. Sort of. The posts ranked for terms nobody was searching for because the "low competition" analysis was just "I didn't see any big sites in these 10 blue links."

## What agent-browser Actually Is

It's a tool that gives Claude Code a real Chromium browser. Not a headless scraper. A full browser with screenshots, clicking, form-filling.

```bash
agent-browser open https://aanvi.app
agent-browser screenshot
agent-browser snapshot -i   # interactive elements
agent-browser close
```

Four commands. Open a URL, take screenshots, interact with elements, close. I didn't build it. It's an open-source Claude Code skill that wraps Playwright into a CLI. I installed it, added `Bash(agent-browser *)` to my blog skills' allowed tools, and updated the keyword research phase to use it.

Total setup time: about 15 minutes. Most of that was figuring out the right Playwright dependencies.

## First Test: Looking at Our Own Site

I told Noru to visit aanvi.app and describe it.

It opened the page, took a screenshot, and came back with: the warm peachy gradient, the hero text, the download buttons, the nav items, a baby journal card peeking in at the bottom. "Warm, inviting, parent-friendly vibes" was its assessment.

Sounds like nothing. But before this, Noru had never seen any of the sites we maintain. It wrote blog posts for a site it couldn't look at. It deployed to a homepage it had never loaded. The blog writing skill had a step that said "Read `src/lib/site.ts` to understand the site features." It was reading source code instead of just opening the website. That's embarrassing in hindsight.

## The Keyword Research Upgrade

The old keyword research worked like this: run `WebSearch`, read the snippets Google returns, guess whether a keyword is "low competition" based on whether Mayo Clinic showed up in the results. The entire decision was based on ten lines of text. No one clicked through to anything.

Now Noru opens Google in the browser, searches the candidate keyword, and looks at the actual results page. Who's on page 1. What the titles look like. Whether there's a "People Also Ask" box with questions nobody's answering. Related searches at the bottom.

Then it clicks into the top-ranking articles. Reads them for real. Sees what angle they took, how deep they went, what they missed. The difference between reading a search snippet and reading the actual article is the difference between guessing and knowing.

For the 3pe1x blog specifically, it also checks Dev.to, Hashnode, and Hacker News to see if a topic is trending or oversaturated. I searched Dev.to for "claude code browser keyword research" while writing this post and found zero results. Content gap confirmed.

## The Buffer Detour

We also tested it on buffer.com. I'm pre-revenue on the Aanvi app, so paying for social media scheduling APIs isn't happening right now. The idea: have Noru use Buffer's free tier through the browser. Open it, create posts, schedule them. No API keys, no monthly fees.

It loaded fine. Full UI visible. We haven't built the automation yet because the app ships first. But the path is there for when we need it.

## What Broke Along the Way

The same day we tested the browser, we spent two hours debugging why `git push` stopped working.

The agent's shell environment couldn't find `gh` (GitHub CLI) auth config. Credentials existed at `~/.config/gh/hosts.yml` but the container's environment didn't have `GH_CONFIG_DIR` set. One line fix:

```bash
export GH_CONFIG_DIR="$HOME/.config/gh"
```

While we were in `.bashrc`, we found a worse problem. The `.profile` file had this gem at the very bottom:

```bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

No `$PATH` at the end. That line overwrites PATH completely every login. NVM, `.local/bin`, everything `.bashrc` carefully built up, gone. This is why I had to manually set PATH every time I SSH'd into the server. Weeks of that. The fix:

```bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:$PATH"
```

Six characters. Weeks of annoyance.

## What the Skills Look Like Now

Both blog skills (Aanvi and 3pe1x) have a browser research step baked into the keyword research phase. The rough flow:

- WebSearch for 2-3 candidate keywords to get a starting point
- Open Google in the browser, search each candidate, check the actual SERP
- Click into top-ranking articles to see their angle
- For 3pe1x: check Dev.to, Hashnode, HN for saturation
- Close browser, pick the keyword

Steps 2-4 are new. Before, the entire keyword decision came from step 1 alone. Now there's real competitor analysis behind the choice.

## Cost

Zero. Playwright and Chromium run on the server. No API, no subscription. Just RAM.

The whole blog pipeline is free tools stacked together: Claude Code, Gemini API free tier for images, WebSearch, and now browser automation. The only costs are the server itself and Anthropic API calls. For a pre-revenue project, that matters a lot.

## Next

I want to add Google Trends to the browser research step. Right now it checks who's ranking but not whether search volume is going up or down. Also want to try the Buffer automation for real once the Aanvi app ships. The browser opened up a lot of possibilities that we haven't explored yet.

But those are next week problems. This week, the agent got eyes. That was enough.

---

*Week 2 of building with Noru. Previous: [I Audited My AI-Generated Blog Posts](/blog/i-audited-my-ai-blogs-they-were-awful). [@itskritix](https://x.com/itskritix)*
