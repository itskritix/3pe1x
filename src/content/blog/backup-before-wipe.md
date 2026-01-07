---
title: "The Complete Backup Checklist Before You Wipe Your Laptop"
description: "Everything you need to save before wiping your machine - from obvious stuff to the files that will haunt you if you forget them."
pubDate: 2026-01-07
tags: ["DevOps", "Productivity", "Guide"]
readingTime: "7 min read"
draft: false
---

## Why I Wrote This

I've wiped machines before. Sometimes on purpose. Sometimes because Windows decided it was time. Every single time, there's that moment of "wait, did I...?" and then the slow realization that no, you did not.

This is the checklist I wish I had. Not some generic "backup your files" advice. An actual list of everything that will make you want to throw your new setup out the window if you forget it.

## The Obvious Stuff (That People Still Forget)

### 1. Personal Files

These are the files you actually care about:

- **Documents** - PDFs, notes, random text files with ideas
- **Photos and videos** - Screenshots, screen recordings, that one meme you saved in 2019
- **Downloads folder** - Yeah, it's mostly garbage. But sometimes there's gold in there. Check it.

### 2. Code and Work Projects

If you're reading this, you probably code. Don't lose your work.

- **All project folders** - Every single one
- **Git repos that aren't pushed** - This is the big one. Run `git status` on everything. If there's uncommitted work, push it or lose it
- **.env files** - These are never in git (hopefully). They're always forgotten. They're always painful to recreate
- **Local scripts** - That random Python script you wrote to automate something? Yeah, back that up
- **Cron jobs** - If you set up scheduled tasks, export them

## Credentials and Secrets

This is where most developers mess up. I've been there.

### 3. SSH Keys

```bash
# Your SSH keys live here
~/.ssh/
```

If you lose your SSH keys:
- Can't push to GitHub/GitLab
- Can't SSH into your servers
- Have to regenerate and update everything

Copy the entire `~/.ssh` folder. All of it.

### 4. Other Secrets

- **GPG keys** - If you sign commits
- **API keys stored locally** - Check your project folders, check your environment variables
- **Cloud credentials** - `.aws`, `.azure`, `.gcloud` folders
- **Password manager export** - If it's not cloud-synced, export it

## Browser Data

You'd be surprised how much of your life lives in your browser.

### 5. Everything in Chrome/Firefox/Whatever

If your browser isn't synced to an account, you need to manually backup:

- **Bookmarks** - Export them
- **Saved passwords** - Export or make sure they're synced
- **Extensions list** - Screenshot your extensions page. You will forget what you had installed
- **Extension configs** - Some extensions have their own settings to export
- **Open tabs** - I know you have 47 tabs open "for later". Save them

## Developer-Specific Stuff

This is the section that will save you days of setup time.

### 6. Package Managers and Toolchains

Rebuilding your dev environment from scratch is painful. Document what you have:

```bash
# List global npm packages
npm list -g --depth=0 > npm-global-packages.txt

# List pip packages
pip freeze > requirements.txt

# List brew packages (Mac)
brew list > brew-packages.txt

# List apt packages (Linux/WSL)
apt list --installed > apt-packages.txt
```

Also backup:
- **Node versions** - If you use nvm, note which versions you have
- **Python virtualenvs** - At least export the requirements
- **Go env** - Your `$GOPATH` and any custom settings
- **Rust/Cargo** - `~/.cargo` folder

### 7. Editor and IDE Configs

Your editor is probably customized exactly how you like it. Don't lose that.

**VS Code:**
- `settings.json`
- `keybindings.json`
- Snippets folder
- Extensions list (Settings Sync extension helps here)

**Terminal:**
- `.bashrc` or `.zshrc`
- `.gitconfig`
- Any custom aliases

**Vim users:**
- `.vimrc`
- Plugin configurations

### 8. Databases and Local Services

If you run anything locally:

- **Database dumps** - Export your Postgres, MySQL, MongoDB data
- **Docker volumes** - These contain data that doesn't exist anywhere else
- **Docker images** - List what you have: `docker images`
- **docker-compose files** - These should be in your project folders, but double-check

## The Stuff Everyone Forgets

### 9. Communication and Notes

- **Slack/Discord exports** - If you need local backups
- **Email archives** - Local Outlook/Thunderbird data
- **Notes apps** - Obsidian vaults, Notion exports (if not cloud), random markdown files

### 10. Licenses and Software

- **License keys** - For paid software you own
- **Offline installers** - That software you downloaded from a sketchy site that no longer exists
- **Custom builds** - Anything you compiled yourself

## The Nuclear Option: Full System Backup

If you want to be completely safe:

### 11. Full Disk Image

Before wiping, create a complete backup of your drive. If you missed something, you can always pull it from the image.

- Use Windows Backup, Time Machine (Mac), or Clonezilla
- Store it on an external SSD/HDD
- Keep a cloud copy if possible

**Two copies minimum. One copy is not a backup - it's a prayer.**

## Where To Store Your Backups

- **External SSD or HDD** - Fast, portable, reliable
- **Cloud storage** - Google Drive, Dropbox, S3, whatever works
- **Another computer** - If you have one

Rule: If your backup exists in only one place, it doesn't really exist.

## Before You Wipe: The Final Check

Go through these questions honestly:

1. **Can I rebuild my dev environment without panicking?** - Do you have your dotfiles, package lists, and configs?

2. **Are my secrets accessible?** - SSH keys, API keys, credentials - can you get to them after the wipe?

3. **Have I tested the backup?** - Can you actually open these files on another machine?

If you answered "no" or "I think so" to any of these - you're not ready yet. Go back and fix it.

## My Backup Strategy

Here's what I actually do:

1. **Dotfiles repo** - All my config files are in a git repo. `.zshrc`, `.gitconfig`, VS Code settings - all version controlled
2. **Cloud sync** - Documents and important files live in cloud storage
3. **GitHub** - All code that matters is pushed
4. **Password manager** - All credentials in one place, cloud-synced
5. **External drive** - Full backup before any major change

It's not perfect, but I haven't lost anything important in years.

## Conclusion

Wiping a laptop should be liberating, not terrifying. The difference is preparation.

Take an hour. Go through this list. Back up everything. Then wipe with confidence.

> Future you will thank current you. Trust me on this one.

---

*Got something I missed? Hit me up on [Twitter](https://x.com/itskritix).*
