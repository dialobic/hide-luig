# [Pigs and Luig] – Oink Jam 2026 Entry

A short hide-and-seek puzzle game made for the **[Oink Jam](https://itch.io/jam/oink-jam)** (January–February 2026).  
**Play it here:** (https://dialobic.itch.io/pigs-and-luig)

## About the game

The goal is simple: **find where Luig is hiding**.

This is the third game in the "Luig hiding" series (after *Hide and Luig* and *Winter and Luig*, both made with Phaser).  
This time everything has been **completely rewritten from scratch in Godot 4** to create a cleaner, more maintainable version of the same core engine I built for the previous games.

### Themes
- **🐷 PIGS** → the whole aesthetic, characters, environment and several puzzles revolve around pigs / pig-themed world
- **💰 EVERYTHING HAS A COST** → every puzzle you solve gives you coins… but you need those coins to actually complete the level and reach Luig. Nothing is free.

### Gameplay in short
- Classic point & click / exploration style
- Find clues and solve small puzzles / riddles
- Collect coins by completing challenges
- Use the coins wisely to open paths or remove obstacles
- Locate Luig's final hiding spot

## Why Godot this time?

After two games with a custom engine in Phaser, I wanted to:
- Have better scene/node organization
- Use Godot's built-in 2D tools and signals properly
- Improve performance and debugging experience
- Prepare reusable code for future Luig games

→ So I remade the entire "Luig engine" in GDScript / Godot — input handling, dialogue system, inventory/coin logic, transition effects, save system, etc.


## Progress & Devlog

As required by Oink Jam rules, progress is documented here with:
- Daily (or almost daily) commits
- Screenshots in `/devlog/` folder (with date in filename or commit message)
- Major refactoring / feature addition messages

You can follow the commit history to see how the game evolved from a blank project to a full jam entry.

## Controls

- **Mouse** → point & click to interact / move
- **Space / Left Click** → interact / advance dialogue
- **ESC** → pause / menu

## Tools & Credits

- **Engine**: Godot 4.3 (or latest stable during jam)
- **Art**: Mostly self-made in Aseprite (+ some free / CC0 assets where noted)
- **Audio**: Self-made sfx + freesound.org where credited
- **Font**: [Nome font se custom o libero]

No AI-generated content was used in code, art, music or text.

---

Thanks for checking out the repo!  
Feedback, bug reports and ratings on itch.io are super welcome 🐷✨

Made for **Oink Jam 2026** – #Pigs #EverythingHasACost
