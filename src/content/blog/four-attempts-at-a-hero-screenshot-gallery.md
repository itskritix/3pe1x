---
title: "4 Attempts at a Hero Screenshot Gallery (and What Finally Worked)"
description: "I needed to showcase app screenshots in a landing page hero section. The first version was ugly. The second broke on mobile. The third was boring. Here's the whole mess."
pubDate: 2026-03-22
tags: ["CSS", "Next.js", "BuildInPublic", "Frontend"]
readingTime: "7 min read"
draft: false
---

I'm building a landing page for [Aanvi](https://aanvi.app), a baby milestone tracking app. The hero section needed to show off the app. Real screenshots, not mockups. Seven App Store screenshots sitting below the headline and CTA.

Sounds simple. Took me four tries.

## Attempt 1: Horizontal Scroll Gallery

The obvious approach. `overflow-x-auto`, `scroll-snap-type: x mandatory`, screenshots in a row. Basic horizontal gallery.

It worked. It also looked terrible. The screenshots were tiny, the scroll container felt like an afterthought, and on desktop it was just a sad little strip of images you had to side-scroll through.

The feedback was immediate: "one of the ugliest designs." Fair.

The problem wasn't the code. The code was fine. The problem was that a horizontal scroll gallery doesn't sell an app. It looks like a file browser. Nobody scrolls sideways through a hero section and thinks "wow, I need this app."

Scrapped it.

## Attempt 2: The Fanned Layout

I'd seen this on other app landing pages — phones arranged in a fan spread, like someone laid them out on a table. Center phone is biggest and in front, side phones are rotated and slightly behind.

Five screenshots. CSS transforms for rotation, `translateY()` for vertical offset, `z-index` for depth, progressive opacity so the outer phones fade out.

```tsx
{/* Center */}
<div className="relative z-[5] w-[210px] lg:w-[260px]">
  <Image src="/assets/screenshots/01-never-miss-milestone.jpg"
    alt="Never miss a milestone" width={520} height={1126}
    className="rounded-2xl shadow-[0_20px_50px_rgba(93,78,78,0.22)]"
    priority />
</div>

{/* Inner right */}
<div className="relative z-[3] -ml-4 w-[150px] lg:w-[200px]"
  style={{ transform: "rotate(4deg) translateY(12px)", opacity: 0.85 }}>
  <Image src="/assets/screenshots/03-milestone-tracker.jpg"
    alt="Milestone Tracker" width={520} height={1126}
    className="rounded-2xl shadow-[0_12px_32px_rgba(93,78,78,0.14)]" />
</div>
```

Negative margins (`-ml-4`, `-mr-4`) create the overlap. Static transforms go in `style` because they never change. No point making Tailwind classes for one-off rotations. Outer phones are `md:` only, so tablet gets 3 phones and desktop gets 5.

Desktop looked amazing. The fanned spread has real visual weight. It says "this is a real app with multiple screens."

Then I checked mobile.

Three phones at 100px width each. Cramped, unreadable, looked like a jumble of colored rectangles. You couldn't tell what any of the screenshots actually showed.

## Attempt 3: Single Floating Phone

Quick fix: hide all the side phones below `sm:`, show just the center screenshot on mobile at a large size with a gentle float animation.

```css
@keyframes float-gentle {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-6px); }
}
```

Desktop kept the fan. Mobile got one big phone floating in space.

It was... fine. Not bad, not good. Just a phone sitting there. The response was "not good, think about other approach on mobile." Which is fair. Most of our users are on mobile. "Fine" isn't enough.

You can't take a desktop layout and shrink it into mobile. They're different problems.

## Attempt 4: The Carousel

Someone shared a reference screenshot from a couples app. Dark card frames, a peek of the next card on the right, swipe to browse, little dot indicators. A proper mobile card carousel.

This meant a completely separate component. Desktop keeps the fanned layout. Mobile gets a new `"use client"` carousel component with its own scroll logic.

```tsx
export function HeroCarousel() {
  const ref = useRef<HTMLDivElement>(null);
  const [active, setActive] = useState(0);

  const onScroll = useCallback(() => {
    const el = ref.current;
    if (!el) return;
    const children = el.children;
    if (!children.length) return;
    const gap = 12;
    const step = (children[0] as HTMLElement).offsetWidth + gap;
    const idx = Math.round(el.scrollLeft / step);
    setActive(Math.min(Math.max(0, idx), slides.length - 1));
  }, []);

  return (
    <div className="sm:hidden">
      <div ref={ref} onScroll={onScroll}
        className="scrollbar-hide flex snap-x snap-mandatory overflow-x-auto gap-3"
        style={{ paddingInline: "calc((100vw - 78vw) / 2)" }}>
        {slides.map((slide, i) => (
          <div key={slide.src} className="flex-none w-[78vw] snap-center">
            <div className="rounded-[1.25rem] bg-[#4a3c3c] p-1
              shadow-[0_12px_40px_rgba(74,60,60,0.25)]">
              <Image src={slide.src} alt={slide.alt}
                width={520} height={1126} className="rounded-xl"
                priority={i === 0} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
```

Each card is 78% viewport width, so you always see a slice of the next one. Dark brown frame (`#4a3c3c`) around each screenshot creates contrast against the cream-colored app UI. Scroll snap makes it feel native.

### The Centering Problem

First version used `snap-start`. Cards snapped to the left edge. On a phone, the active card sat flush against the left side with empty space on the right.

Switching to `snap-center` alone doesn't fix it. The first and last cards need padding so they can actually reach the center of the viewport. The fix:

```css
paddingInline: calc((100vw - 78vw) / 2)
```

This adds horizontal padding equal to half the remaining viewport space. First card starts centered, last card ends centered, everything in between works.

### The Frame Thickness

Started at `p-2.5` (10px). Too thick, the dark border overpowered the screenshot. Dropped to `p-1.5` (6px). Still chunky. Ended at `p-1` (4px).

### Dot Indicators

Animated pagination dots that track the active slide. The active dot stretches wider and changes color. Nothing fancy:

```tsx
<div className="mt-5 flex justify-center gap-1.5">
  {slides.map((_, i) => (
    <div key={i} className={`h-1.5 rounded-full transition-all duration-300 ${
      i === active ? "w-5 bg-[#e88b8b]" : "w-1.5 bg-[#d4c4bc]"
    }`} />
  ))}
</div>
```

Active dot: 20px wide, coral. Inactive: 6px, sand-colored. The `onScroll` handler calculates which card is closest to center and updates the state.

The response to the final version: "this looks good as fuck."

## The Final Structure

The final hero section renders completely different components based on viewport:

```tsx
{/* Mobile — swipeable card carousel */}
<Reveal variant="fade-up" delay={0.32} className="mt-14 sm:hidden">
  <HeroCarousel />
</Reveal>

{/* SM+ — fanned showcase */}
<Reveal variant="scale" delay={0.32} className="mt-16 hidden sm:block">
  {/* 5-phone fan layout */}
</Reveal>
```

No media queries trying to make one layout work everywhere. Two separate implementations, toggled with `sm:hidden` and `hidden sm:block`. The carousel component doesn't even load on desktop.

This felt wrong at first. Two layouts for the same content? But a single responsive layout that's mediocre everywhere is worse. Desktop has hover and space. Mobile has swipe and fat thumbs. Pick one or build two.

## What I'd Do Differently

The four iterations happened in one session. Each attempt was maybe 20-30 minutes of coding before the feedback came in. Total wall-clock time for the whole thing was a couple hours.

If I'd spent an hour looking at reference designs _before_ writing any code, I might have skipped attempts 1 and 3 entirely. The fanned desktop layout was a good instinct. The mobile carousel was the obvious answer once I saw the reference. I just got there by trying two bad ideas first.

But honestly? Getting a bad version in front of someone in 20 minutes and hearing "this is ugly" beats spending 2 hours perfecting something in isolation.

## Scroll Snap Gotchas

Use `snap-center`, not `snap-start`. I made this mistake. `snap-start` pins cards to the left edge and it looks broken.

Your container needs padding of `(viewport - card_width) / 2` for the first and last cards to reach the center. Without it, they're stuck at the edge. I didn't find this in any tutorial. Had to figure it out from the visual bug.

Your `onScroll` index math is probably wrong. `scrollLeft / cardWidth` ignores the gap. It's `scrollLeft / (cardWidth + gap)`. Cost me 10 minutes of debugging off-by-one dot indicators.

Use `scrollbar-hide`. Nobody wants a scrollbar on a mobile carousel.

---

*Building [Aanvi](https://aanvi.app) in public. Find me on [X @AKritix](https://x.com/AKritix).*
