OSC-Demos
=========


A collection of simple projects meant to show off the use of OSC.




AnimatedBookCover
-----------------

This requires the [AnimataP5-ng](https://github.com/Neurogami/AnimataP5-ng) library.

It works as the target of an [osc-scripter](https://github.com/Neurogami/osc-scripter) script.

You can see this is action in the videos [An Intro to osc-scripter, Part 1](http://www.youtube.com/watch?v=DcOrADVDLo4) and  [osc-repl: A helper tool for Open Sound Control (OSC)](http://www.youtube.com/watch?v=_mVJs42Q_Js).

Run by itself, the handsome wiggly fellow on the book cover should shimmy about.

There are `osc-scripter` scripts to drive assorted animations of the pink background waves.

Each of these ends with the `.oscr` file extension.  To use them, first start the `AnimatedBookCover.pde` sketch.

Then, from inside the `AnimatedBookCover` folder, run `osc-scripter` and pass in the name of one of the `oscr` scripts.



Landscape
---------

This requires the [AnimataP5-ng](https://github.com/Neurogami/AnimataP5-ng) library.  

That will get it running, but the real fun is when it is the target of an [osc-scripter](https://github.com/Neurogami/osc-scripter) script or two.

First run the `Landscape.pde` sketch.  Then, from inside the `Landscape` folder, run `osc-scripter landscape.oscr`.

This is a simple looping script that alters some ambient layers in the `Landscape.nmt` Animata scene.

The more interesting example requires you to have [Renoise](http://www.renoise.com/), a very slick DAW/tracker.  You should buy it, but the free trial version should be fine for running the OSC demos.


So, load `Renoise` with the `Renoise\osc-scripter-demo-song.xrns` song. Do not start the song, but do make sure that the OSC server is running and listening on UDP on the default port, 8000.

Then, from the `OSC-Demos/Renoise` folder run `osc-scripter song-mixer/song-mixer.oscr` 

This script will send OSC messages to Renoise to manipulate tracks. It also loads a helper file that listens for MIDI messages coming from Renoise.  There's a track in the song specifically meant to send MIDI events.

You will need two gems for this: `unimidi` and `midi-eye`.

The MIDI helper file, `Renoise/midi-listener/midi-listener.rb`, lets you map MIDI message events to handlers that can, in turn, create  OSC script commands.   In this example, changes in the notes played by the lead tracks are mapped to changes in filter colors in the `Landscape` sketch.

This demo shows a number of things. One, you can run multiple `osc-scripter` instances, each with specific behaviors, to get a more complex result. Two, since `osc-scripter` can load helper files in works as a general server responding to whatever you can teach it.  Three, there can be a noticeable lag in processing messages.

Depending on your system you may see, quite clearly, a delay from when the Renoise track changes the lead notes and when the Processing sketch changes the filter colors.



License
========

Code is licensed under the MIT license 

All artwork is property of James Britt and Neurogami, LLC



The MIT License 

Copyright (c) 2013 James Britt / Neurogami

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Feed your head.

Hack your world.

Live curious.
