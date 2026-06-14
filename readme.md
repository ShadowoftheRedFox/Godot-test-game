# Introduction

This is just a public repository I share with friends about a game, or just about anaything, that I want to do.

Ideas and other things are available in the [lore](/lore) folder ([shortcut to ideas](/lore/idea.md)).

More documentation in [documentation](/documentation/)

## Why Godot?

Because I did a GameJam with it, it's the game engine i'm the most confortable with. I also tried the other engine, and Godot is the most simple to use for me.

## Implementations

There are multiple things currently implemented:
	- An infinite world generated with chunks.
		- Pros: Light, can change chunk size and render distance easily.
		- Cons: Seams between chunk are not, well, *seamless*. LOD made by hands
	- A laboratory, where I play with different game mechanics in a fla world.

Things implemented:
- inventory system
- items
- fly
- console and commands
- entiry spawner

I try to keep the functionnality with inheritance and components, so that any "main" component (Player, and only Crate for now) only need to reference those components and made them communicate, and some in between logic.

# Controls

The keys are physical.
Movement: WASD
Jump: Space
Crouch: Left Ctrl
Interact: F
Back: Escape or Backspace
Special up: E
Special down: A
Console: f1

Double jump to fly with the player.
Crouch is only used to go down when flying for now.
Sepcial up and down are special buttons to use without care in a specific scenes, to test feature.
