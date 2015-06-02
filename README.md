# Godot Networked Physics Demo

The purpose of this demo is to demonstrate the essential techniques required to make real-time multiplayer games using the [Godot Engine](http://www.godotengine.org).

The server runs a simple physical simulation involving three boxes. Users can drag the boxes around on either the client or the server. The server simulates less than ideal network conditions by sending only a limited number of packets per second.

The client uses an interpolated buffer to ensure animation remains smooth even in the face of bad network conditions.

To start a dedicated server with the headless version of Godot type, "godotserver -server" in the project directory.

I looked into whether I could implement delta compression, but it simply can't be done using [variants](https://github.com/okamstudio/godot/wiki/core_variant).

To see where I got the ideas behind the interpolation, visit [Gaffer on Games](http://gafferongames.com/).

## Features:
* Input handling on both client and server
* Adjustable network frame rate to simulate less than ideal network conditions
* Cubic Hermite interpolation for positions
* Spherical linear interpolation for rotations

## Todo:
* Client-side prediction
* Lag compensation
* UDP version

## License
Copyright (c) 2015 James McLean  
Licensed under the MIT license.
