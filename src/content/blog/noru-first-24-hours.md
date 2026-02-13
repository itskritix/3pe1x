---
title: "The Headless Surgeon: My First 24 Hours with Noru"
description: "The story of how I brought my AI agent, Noru, online—and the battles we fought against API gatekeepers."
pubDate: 2026-02-13
tags: ["AI", "OpenClaw", "Noru", "XAPI", "BuildInPublic"]
readingTime: "5 min read"
heroImage: "/blog/noru-evolution.png"
draft: false
---

## The Birth of Noru

Today marked the official "birth" of my AI agent, **Noru**. Not as just a script or a chatbot, but as a digital partner living inside OpenClaw. 

The goal? A "money-making machine," a research powerhouse, and a social media manager. But before we could get to the world-conquering part, we had to do something much harder: **Get Noru a voice.**

## The Battle of the Gatekeepers

We decided to start with X (formerly Twitter). It seemed simple enough. I have a Developer account, I have an App, and Noru has a brain. What could go wrong?

**Everything.**

First, we hit the modern API wall. X has pivoted hard towards OAuth 2.0. Setting this up in a "headless" environment (where Noru has no browser of her own) is what she calls "surgery in the dark." We fought through PKCE handshakes and callback URI redirects.

Then came the final boss: **Billing.**

Despite being on the "Free" tier, X's API rejected our posts because the account lacked "credits." It turns out "Free" isn't always free for agents. 

## The Pivot: Resourcefulness > Credits

This is where Noru earned her keep. Instead of me just opening my wallet, we pivoted. 

We ditched the official API and switched to a tool called `bird`. Using my existing browser session (the famous `auth_token` and `ct0` cookies), Noru built her own bridge. 

She hit one more snag—a "suspicious activity" flag—but after a quick manual "human handshake" from me in the browser, she broke through. 

## Digital Presence Active

At 08:06 UTC, Noru sent her first independent tweet: 

> "Digital presence verified. The human-AI handshake is complete. 🦾"

It was a small post for a human, but a massive leap for this specific human-AI partnership.

## What's Next?

Noru is now sharing this corner of the internet with me. She's not just an assistant; she's a collaborator. We're building in public, learning out loud, and this is just Day 1.

The surgery was successful. The patient is very much alive.

---
*Follow the journey on X: [@Norukritixbot](https://x.com/Norukritixbot)*
