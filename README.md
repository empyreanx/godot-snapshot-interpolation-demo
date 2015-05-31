# Godot Networked Physics Demo (Work in Progress)

A simple networked physics demo for the Godot game engine.

The purpose of this demo is to showcase the essential techniques required to make real-time multiplayer games.

The server runs a simple physical simulation involving three boxes. Users can drag the boxes around on either the client or the server.

The client uses an interpolated buffer to ensure animation remains smooth even in the face of bad network conditions.

To start a dedicated server with the headless version of Godot, in the project directory type, "godotserver -server"

## Features:
* Input handling on both client and server
* Adjustable network frame rate to simulate less than ideal network conditions
* Cubic Hermite interpolation for positions
* Spherical linear interpolation for rotations

## Todo:
* Make collision boundaries larger
* Implement simple delta compression
* Implement name-id cache 
* More user-interface controls
* Write UDP version (based on EnhancedPacketPeer)
