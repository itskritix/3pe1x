---
title: "We Audited Our App Before Apple Could Reject It"
description: "Apple rejects ~40% of first-time app submissions. We decided to reject ourselves first. Found 16 issues in our React Native app that would have killed the review."
pubDate: 2026-02-26
tags: ["iOS", "React Native", "App Store", "BuildInPublic"]
readingTime: "7 min read"
heroImage: "/blog/we-audited-our-app-before-apple-could-cover.png"
draft: false
---

## The Plan Was to Submit This Week

We're building Aanvi, a baby memory journal. React Native, Expo SDK 54, Firebase backend. 166 TypeScript files, 63 components, milestone tracking, family sharing, the whole thing. We'd been aiming for a Feb 28 submission.

Then I looked up the rejection rate for first-time iOS submissions.

Around 40%. Apple rejected nearly 2 million submissions in 2024. The most common reason is "Performance" which sounds vague until you read the specifics: crashes, broken flows, placeholder text, dead links. The second most common is privacy violations. The third is misleading metadata.

We weren't going to submit blind and wait a week to find out what we missed. Instead, we built a checklist from Apple's actual rejection data and ran it against our own app.

We failed 16 out of roughly 25 categories.

## How We Built the Checklist

Noru (my AI agent) did the research. Scraped Apple's App Review Guidelines, cross-referenced with rejection reports from indie devs on Reddit and the Apple developer forums, and pulled the actual review criteria that reviewers use during the process.

We grouped everything into categories: privacy, performance, design, login, legal, content moderation, metadata, in-app purchases. Each category got specific yes/no checkpoints. Not "does your app handle privacy?" but "does your app show a privacy policy link inside the Settings screen AND in App Store Connect?"

Then we opened the app and went through every single item.

## The 16 Failures

### Privacy was a mess

**No privacy consent during signup.** Users create an account and start using the app. At no point does the app ask "do you consent to us collecting your data?" Apple has been rejecting apps for this since 2024. We had the privacy policy written. It was on the website. It just wasn't shown during the signup flow.

**Privacy policy and Terms of Service not accessible from the profile page.** Apple wants these linkable from inside the app. Ours were only on the website. Reviewers check this specifically.

**Missing `NSLocationWhenInUseUsageDescription`.** The app uses a globe view to show where memories were created. It requests location access. The permission string in Info.plist was empty. iOS would show a blank dialog asking for location permission with no explanation. Instant rejection.

**GDPR data export behind the paywall.** Users have a right to export their data under GDPR. We had a data export feature. It was locked behind the premium subscription. You cannot charge people to access their own data.

**Incomplete account deletion.** Apple requires in-app account deletion since 2022. We had a delete button. It deleted the auth record but left Firestore data, storage files, and family memberships intact. A reviewer would check.

**COPPA compliance missing.** The app is for parents tracking their babies. That's kid-adjacent content. COPPA has specific requirements about data collection for children under 13, and we hadn't addressed any of them.

### Features that didn't exist

**No memory edit or delete.** You could create a memory. You could not edit it. You could not delete it. I don't know how this shipped without us noticing, but there it was. No edit screen, no delete confirmation, no swipe-to-delete. Once a memory was created, it was permanent. Apple's reviewers would flag this under Guideline 2.1 (App Completeness).

**No family member removal.** You could invite grandma. You could not uninvite grandma. No "remove from family" button, no "leave family" option.

Same story for comments (no delete) and baby profiles (no delete). We'd built the "add" half of every feature and never built the "remove" half. Four separate places in the app where you can create something permanent with no undo.

### The Ugly Bugs

**Paywall infinite loading state.** The subscription screen would sometimes just spin forever. No timeout, no error message, no retry button. Just a loader that never stops. A reviewer hitting this during their test would reject immediately.

**Memory leak in the intro screen.** The onboarding animation was leaking memory. Not dramatic enough to crash, but enough that Instruments would flag it. Reviewers have access to profiling tools.

**Dark mode mismatch.** Half the app respected system dark mode. The other half pretended dark mode didn't exist. White-on-white text on some screens, dark-on-dark on others. This one is embarrassing because you can literally just turn on dark mode and look at your own app. We hadn't.

**No offline handling.** No connection? Blank screens. No error, no cached data, no "you're offline" banner. Just white rectangles where content should be.

### Missing Basics

**No support or contact information anywhere.** No email, no link to a support page, no feedback form. If a user had a problem, there was no way to reach us from inside the app. Apple checks for this.

**Zero accessibility labels.** None. Not a single VoiceOver label on any interactive element. 63 components, zero accessibility support. Apple doesn't reject for this every time, but they can, and the fact that we had literally zero labels is the kind of thing a reviewer flags.

## What Was Actually Fine

It wasn't all failures. The app launched without crashing. The metadata was accurate. Screenshots matched the actual UI. We weren't using any external payment processors (Firebase handles subscriptions through the stores). The app icon met spec. Category selection was correct.

The core functionality worked: create a memory with a photo, view the timeline, see milestones. The basic path through the app was solid. The failures were all in the edges. Account management, error states, permission descriptions, legal compliance. The stuff you don't think about when you're focused on making the main feature work.

## Fixing It

We're not submitting on the 28th. That was obvious after the audit. The list is 16 items and most of them aren't one-line fixes. Account deletion needs to cascade through Firestore, Storage, and Cloud Functions. Memory edit needs a whole new screen. COPPA compliance needs legal review.

Some of these we're fixing before submission. Some we're deferring to a 1.1 update (like full VoiceOver support, which is a significant project). The non-negotiable ones: privacy consent, account deletion, data export, and the paywall loading bug. Those are submission blockers.

The dark mode fix is just tedious. Every screen needs to be checked. The offline handling needs a whole caching strategy we haven't designed yet.

## The One-Afternoon Version

The whole audit took an afternoon. Turn on dark mode and go through every screen. Turn off wifi and go through every screen. Try to delete everything you can create. Check if your permission dialogs say something. Open your paywall and wait. Look for your privacy policy from inside the app.

That's it. No tools required. Just use your own app the way a reviewer would: skeptically, slowly, looking for the thing that doesn't work.

The fixes will take us two weeks. Submitting without the audit would have cost a week of review time, then however long to fix, then another review cycle. Finding the problems ourselves is faster than having Apple find them for us.

---

*Building Aanvi in public. Previous: [One Line in .profile Broke My AI Agent's Git Push](/blog/one-line-in-profile-broke-everything). [@itskritix](https://x.com/itskritix)*
