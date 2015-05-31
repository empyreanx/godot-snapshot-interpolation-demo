# Godot Networked Physics Demo (Work in Progress)

A simple networked physics demo for the Godot game engine.

The server runs a simple physical simulation involving three boxes. Users can drag the boxes around on either the client or the server.

The client uses an interpolated buffer to ensure animation remains smooth even in the face of bad network conditions..

## Todo:
* Configuration file
* Add dedicated server script
* Implement simple delta compression
* Implement name-id cache
* More user-interface controls
* Fix bugs 
* Write UDP version (based on EnhancedPacketPeer)

##Known Bugs:
* Potential divide by zero in KinematicBuffer
