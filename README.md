# Snapshot Interplation Demo

## Introduction
The purpose of this demo is to demonstrate essential techniques required to make real-time multiplayer games using the [Godot Engine](http://www.godotengine.org).

The server runs a simple physical simulation involving three boxes. Users can drag the boxes around on either the client or the server. The server simulates less than ideal network conditions by sending only a limited number of packets per second.

The client uses an interpolated buffer to ensure animation remains smooth even in the face of bad network conditions.

To start a dedicated server with the headless version of Godot type, "godotserver -server" in the project directory.

To see where I got the ideas behind the interpolation, visit [Gaffer on Games](http://gafferongames.com/).

It looks like I might be able to do delta compression after all thanks to some changes being made by Juan.

I did more reading about client-side prediction and lag compensation, and I've concluded that both techniques are inappropriate for this demo.

## Features
* Input handling on both client and server
* Adjustable network frame rate to simulate less than ideal network conditions
* Cubic Hermite interpolation for positions
* Spherical linear interpolation for rotations

## Todo
* Use UDP instead of TCP

## License
Copyright (c) 2015 James McLean  
Licensed under the MIT license.
