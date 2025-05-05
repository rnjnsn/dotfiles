# My Dotfiles

These are the dotfiles I use on my personal Linux setup. Feel free to explore, fork, or borrow anything you find useful.

## About

This setup is tailored for a minimal, keyboard-focused workflow running on:

- **Arch Linux**
- **Hyprland**
- **Lenovo ThinkPad X1 Carbon Gen 13**
- **HHKB (Happy Hacking Keyboard)** 

I manage them using the **bare Git repo method**.

## Shameless Theft

Many of the ideas, scripts, and config styles here are directly copied or inspired by people far more experienced:

- [@lukesmithxyz](https://github.com/LukeSmithxyz)
- [@mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [@rwxrob](https://github.com/rwxrob)
- [@tplasdio](https://codeberg.org/tplasdio)

If you like what you see here, go check out their setups — they’re full of smarter and more refined solutions.

## What's Not Included

This repo only includes **public, non-sensitive** config files.

Private configs like the following are tracked separately in a private repo:

- `.ssh/`, `.gnupg/`, authentication tokens
- `.config/git/credentials`, machine-specific secrets

## Install (At Your Own Risk)

If you're curious or want to try this setup:

```bash
git clone --bare git@github.com:yourusername/dotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles checkout
