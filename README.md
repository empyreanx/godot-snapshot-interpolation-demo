# Godot Networked Physics Demo (Work in Progress)

A simple networked physics demo for the Godot game engine.

The server runs a simple physical simulation involving three boxes. Users can drag the boxes around on either the client or the server.

The client uses an interpolation buffer to ensure animation remains smooth even in the face of bad network conditions..

## Todo:
* Add documentation to code
* Add delta compression
* More user-interface controls
* Fix bugs:
	- Division by zero in DelayBuffer
* Add dedicated server script
* Write UDP version (later)
