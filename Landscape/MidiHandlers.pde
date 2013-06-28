import java.lang.reflect.Method;

/*

   There really needs to be a P5 library that defines core AnimataP5 OSC methods so that
   you don't have to copy the damn code into every sketch.

   Or just bundle it with AnimataP5-ng.  


   Either way, the handlers for basic scene manipulation should be separate from
   code that does higher-level things.

   For example, we want this sketch to move in time with a Renoise piece.

   We want high-level actions, such as "show something that maps well to the dual 
   chip tones given their pitch values."

   Or "do something useful on each C3 Note Off".

   BTW, the song-mixer code is handling the dual-tone thing.  Does it too need something 
   more high-level so that it can pick two tones and then send those value both to
   Renoise and to this sketch?


   Here's another issue:

   OscP5 has you define a methods, in *one* place, to catch OSC events.

   If that method is define in some library then how do you add new handlers?

   We can easily add new code that does the actual work, but how to add new pattern
   matching?

   Suppose we use a HashTable or something to store patterns of some kind.

   Enough data so that `oscEvent(OscMessage)` can run through it to see if it matches
   on something, and then magically invoke a method.

   What's the overhead? How can it lead to method invocation?

   Use callByName or something?

http://forum.processing.org/topic/getmethod-in-processing


Or just use a delegating method at the end of oscEvent();

 */

void renderDualTones(String tone1, String tone2) {
  println("renderDualTones called with " +  tone1 + " and  " + tone2);
}

