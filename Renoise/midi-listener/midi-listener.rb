#!/usr/bin/env ruby

require 'pp'
Thread.abort_on_exception = true

# Ubuntu: May have to call
#     sudo modprobe snd-virmidi
#
# and then adjust Renoise or whatever is sending midi
#   http://jorgan.999862.n4.nabble.com/Virmidi-in-Ubuntu-td3439207.html
#


# http://tx81z.blogspot.com/2011/06/high-level-midi-io-with-ruby.html
require 'unimidi'
require 'midi-eye'


class MidiListener

  ADDR = 0
  NOTE_ON =1
  NOTE_OFF =2

  def initialize 
    @input = UniMIDI::Input.use :first
    @output = UniMIDI::Output.use :first
    @v1
    @v2

    @flag = false

    @registry = {}
    @event_tracker  = Hash.new 0 
    @event_registry = {}
  end


  def event_tracker
    @event_tracker
  end

  def register_method_for_event verbose_event_name, method_name, *method_args
    puts "Register '#{verbose_event_name}' to call #{method_name}"

    @event_registry[verbose_event_name] ||= []
    @event_registry[verbose_event_name] << [method_name, [*method_args]]

    puts "@event_registry[verbose_event_name]:  #{@event_registry}"

  end

  def register_message_for_note_name note_name, addr_pattern, note_on_value, note_off_value=nil
    @registry[note_name] = [addr_pattern, note_on_value, note_off_value]
    puts "Now have @registry: #{@registry.inspect}"
  end

  def assign_runner r
    @runner = r
  end

  def track_event event
    #    @event_tracker[event[:message].name] ||= 0
    @event_tracker[event[:message].verbose_name] += 1
    puts "\n\t\t\t\t\t#{event[:message].verbose_name} => #{@event_tracker[event[:message].verbose_name]}\n\n"
  end

  def run
    puts "\n************************ RUN MIDI ************************ "

    listener = MIDIEye::Listener.new @input

    listener.on_message do |event|


      #     break unless event[:message].verbose_name =~ /Note On/
      # puts event.pretty_inspect
      verbose_name = event[:message].verbose_name

      #puts "event[:timestamp] = #{event[:timestamp]}"

    #  puts "\n#{'+'*80}\n++++++++++++++ #{event[:message].note} '#{event[:message].name}' : '#{verbose_name}' +++++++++++++++++++++++++++++++++++++++++++++\n\n" 
      track_event event

#      puts event_tracker.pretty_inspect


##      puts "event[:message].to_s  = #{event[:message].to_s } "
      if event[:message].to_s =~ /NoteOn/  
        if msg = @registry[event[:message].name] 
          if msg[NOTE_ON]
  ##          puts "######################  on #{msg[ADDR]}  ##########################################"
            @runner.execute_command %~#{msg[ADDR]}   #{msg[NOTE_ON]}~, :skip_loop_appending
          end
        end

      elsif event[:message].to_s =~ /NoteOff/
        if msg = @registry[event[:message].name]
          if msg[NOTE_OFF]       
    ##        puts "######################  off #{msg[ADDR]}  ##########################################"
            @runner.execute_command %~#{msg[ADDR]}   #{msg[NOTE_OFF]}~, :skip_loop_appending
          end
        end
      end



      if handlers = @event_registry[verbose_name]
#        puts " FOUND REGISTERERD METHOD HANDLER FOR '#{verbose_name}': #{handlers.pretty_inspect}"
        handlers.each do |handler| 
      #    puts "\n===================================  #{handler.inspect} ========================================== "
          m = handler.first
          send m, *handler[1] 
        end
      else
#        puts "NO HANDLER FOR '#{verbose_name}' in  #{@event_registry.pretty_inspect}"
      end

    end

    Thread.new do 
      listener.start
    end


  end

end


def create_listener
  @ml = MidiListener.new
  puts "-------- Create MidiListener.new"
  @ml.assign_runner self
end

def register_message_for_note_name note_name, addr_pattern, note_on_value, note_off_value=nil
  @ml.register_message_for_note_name note_name, addr_pattern, note_on_value, note_off_value
end


def register_method_for_event verbose_event_name, method_name, *method_args
  puts "#### register_method_for_event #{verbose_event_name}, #{method_name}, #{method_args.inspect}"
  @ml.register_method_for_event verbose_event_name, method_name, *method_args
end

def run_listener threaded=nil

  puts '---------------------------------'


  Thread.new do
    puts '-------75 --------------------------'
    @ml.run
    sleep 3
  end
end

puts "Loaded #{__FILE__}"

if __FILE__ == $0
  ml = MidiListener.new
  ml.register_message_for_note_name 'C3',  "/animata/osc-for-artists/layer/waves/alpha", 0.0, 1.0
  t = ml.run
  t.join
end
