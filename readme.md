# Introduction

This is just a public repository I share with friends about a game, or just about anaything, that I want to do.

Ideas and other things are available in the [lore](/lore) folder ([shortcut to ideas](/lore/idea.md)).

## Why Godot?

Because I did a GameJam with it, it's the game engine i'm the most confortable with. I also tried the other engine, and Godot is the most simple to use for me.

## Implementations

There are multiple things currently implemented:
	- An infinite world generated with chunks.
		- Pros: Light, can change chunk size and render distance easily.
		- Cons: Seams between chunk are not, well, *seamless*. LOD made by hands
	- An inifite world using clipmap. Same idea as chunks, but with a single mesh.
		- Pros: LOD built into the mesh itself, seamless.
		- Cons: Need to recalculate the mesh when the player move. Hard to change the LOD on the fly.
	- A laboratory, where I play with different game mechanics in a fla world.
	
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

Double jump to fly with the player.  
Crouch is only used to go down when flying for now.  
Sepcial up and down are special buttons to use without care in a specific scenes, to test feature.

They are used in [Worlds/ClipMap](/scenes/worlds/ClipMap) to tweak a ratio when displacing the map (I tried to remove the jumps when snapping to the player new position), and in [Worlds/test] to "shoot" the crate. Up to damage, down to heal.

# Bugs/Todos:
- On ClipMap, when the mesh is snaped to displace with the player movement, there are jumps. The map doesn't move in reverse of the player.
- When turning the camera left and right, the player body spin like crazy.
- Chunks generation can be slow, they need their own thread.
