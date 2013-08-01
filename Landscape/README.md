This interwingles MIDI notes emitted from Renoise, plus an `osc-scripter` script, and a P5 sketch.

The scripts and such are spread out, depending on what you want to do.

The most interesting one mixes an OSC script for midi bridge while you also run landscape.oscr

There's a Renoise song set up to work with this.

To run this set-up:

- Run the Landscape P5 sketch

- Launch landscape.oscr.  This seems to do little more than randomly adjust noise layers

- From the `~/Dropbox/repos/OSC-Demos/Renoise` folder, run  `osc-scripter song-mixer/song-mixer.oscr`
  This needs to run from that folder because the script makes some path assumptions; it will load a helper script for midi-bridge

That script should kick of Renoise with `renoise/transport/start` and the MIDI triggers should be fed back through that script as commands for the P5 sketch.  The panels should change color based on the tones played.







