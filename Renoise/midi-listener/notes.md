# Grabbing events from Renoise #

Simple example to have Renoise send some "trigger MIDI" which should be picked up a MIDI listener which then relays an OSC message.

You don't have to use Renoise if you only want to recieve MIDI.

What's needed is some way  to keep track of song movement.

For example, a midi track could send a specific note at the end or start of each pattern; the script runner would have grab this and update a persistant counter.

There's a risk that a midi note might can lost someplace.  What else can we send? SMTP or something?

Maybe it doesn't matter?

Assume for now that all messages make it to the scripter.



## Sharing code ##

The midi hook cannot have hard-code handlers. 

Also, the current approach of registeing for on and off is wrong.

It seems to assume a single OSC arg for on or off, where Renoise OSC messages takk all sorts of arguments.

There needs to be some other way to have certain midi events map to code and OSC actions, ideally by working back in to the osc-scripter way of doing things. ` register_message` needs to take a comeplete message name, and metod to call, and the args to apps to that method (sort of like mapping `:foo||x||y||z` to a MIDI event.



## Things to consider ##


The block loop thing seems to work like this:

Set the loop size; it's a fraction (1/2, 1/4, 1/5 ...).

Play the pattern.

If you switch block loop on it starts to loop withing whatever fraction of the pattern you happen to be in.

For example, if you set it to 1/8 on a 64-line pattern, and turn on BL just as it plays line 25 then it loops over lines 24 to 3.


We could have BL set to smallish fraction and randomly turn it, while counting some other beat trigger as a way to know how many measures have been played.  We would have to be sure we had a midi trigger withing each BL chunk.


### Renoise OSC  ###

`
/renoise/transport/loop/block_move_backwards
Move the Block Loop one segment backwards

/renoise/transport/loop/block_move_forwards
Move the Block Loop one segment forwards

    /transport/loop/block boolean  (1 or 0)

    /renoise/song/track/XXX/device/XXX/set_parameter_by_index number  number
  
  `

That last one is slick but you have to know some details of the tracks and effects to use it.


For example, by default it seems that device 1 is the built-in track properties: volume, panning, etc.

If you add any effects, such as `mpReverb`, they are addresable by subsequent device indices.

If you know the device index then you have to know the order of properties you can change and what values they can take (though generally it is a float from 0 to 1).

Can a device be turned on and off?

`
  /renoise/song/track/XXX/device/XXX/bypass boolean

`

Boolean means 1 or 0.


What about ding things by name? How would you even know the parameter names?

`/renoise/song/track/XXX/device/XXX/set_parameter_by_name string number`

You can get them from the GUI.  Case-insensitive, so you can capitalize or not as you wish.

You still need to know the device index.


We can "play"  a lead with 
`
/renoise/trigger/note_off(number, number, number)
Trigger a Note OFF.
arg#1: instrument (-1 chooses the currently selected one)
arg#2: track (-1 for the current one)
arg#3: note value (0-119)
`


