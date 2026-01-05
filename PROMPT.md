# 3P1X LABS - Master Task

## Overview
Build 3P1X LABS - a brutalist portfolio website for Ganesh Dole (@itskritix).

## Modular Prompts (for parallel RALPH loops)

This project is split into modular prompts in the `prompts/` folder:

| Prompt | Task | Can Run In Parallel |
|--------|------|---------------------|
| PROMPT-1-setup.md | Project init with Astro CLI | Must run first |
| PROMPT-2-home-about.md | Home & About pages | After Phase 1 |
| PROMPT-3-labs.md | Labs/Projects page | After Phase 1 |
| PROMPT-4-gallery.md | Keep Going gallery | After Phase 1 |
| PROMPT-5-contact-polish.md | Contact & final polish | After all others |

## How to Run Parallel RALPH Loops

### Sequential (Single Claude)
```powershell
# Run all phases sequentially
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-1-setup.md" -MaxIterations 20
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-2-home-about.md" -MaxIterations 20
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-3-labs.md" -MaxIterations 20
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-4-gallery.md" -MaxIterations 20
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-5-contact-polish.md" -MaxIterations 20
```

### Parallel (Multiple Claudes)
```powershell
# Terminal 1: Setup first
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-1-setup.md" -MaxIterations 20

# After Phase 1 completes, run these in parallel (3 terminals):
# Terminal 2:
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-2-home-about.md" -MaxIterations 20

# Terminal 3:
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-3-labs.md" -MaxIterations 20

# Terminal 4:
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-4-gallery.md" -MaxIterations 20

# After all complete, run polish:
.\ralph-loop.ps1 -PromptFile "prompts/PROMPT-5-contact-polish.md" -MaxIterations 20
```

## Quick Start (All-in-one)

If you prefer a single RALPH loop that does everything:

```powershell
.\ralph-loop.ps1 -PromptFile "PROMPT.md" -MaxIterations 100
```

---

## Full Task (for single RALPH loop)

Build **3P1X LABS** with these requirements:

### Tech Stack
- Astro (use `npm create astro@latest`)
- Tailwind CSS (use `npx astro add tailwind`)
- TypeScript

### Design: BRUTALIST
- NO rounded corners
- NO shadows  
- NO gradients
- Thick 2px borders
- Monospace fonts (JetBrains Mono)
- Colors: #0A0A0A / #FAFAF8 / #C45A3B

### Pages
1. Home - "3P1X LABS" hero
2. About - Bio, skills, experience, GitHub activity
3. Labs - Project cards with filtering
4. Keep Going - Image gallery with lightbox
5. Contact - Terminal-style

### Personal Data
- Name: Ganesh Dole
- Handle: @itskritix
- Location: Pune, India
- Role: Founding Engineer @ NIDANA
- Skills: React, Next.js, NestJS, TypeScript, Python, etc.

### Projects
- BrainBox (Private) - Workspace platform
- TypeCount (Open Source) - Keystroke analytics
- wisper, assetpipe, nanochat, Forum-indieGamies, Tenzies
- Forks: OpenDeepWiki, web-interface-guidelines, etc.

### Keep Going Images
Copy from D:\itskritix\keep-going-images\ to public/keep-going/

## Success Criteria
- All 5 pages working
- Brutalist design (no rounded corners, no shadows)
- Responsive
- `npm run build` succeeds

## Completion
Output: <promise>COMPLETE</promise>

---

## Notes for Claude
- Use CLI tools: `npm create astro@latest`, `npx astro add tailwind`
- Run `npm run build` frequently
- NO dev mode - production builds only
- Check git for previous progress
