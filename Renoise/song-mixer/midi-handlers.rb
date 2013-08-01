require 'pp'

require 'osc-ruby'


# This class is reopening the original MidiListener that is defined in the 
# confusingly named midi-hook/midi-hook.rb
#
class MidiListener
  @last_mute  = nil
  @unmute     = nil
  @lead_intr  = 8

  include  OSC



  def relay_to_ap5 verbose_name
   # Need to send OSC messages to an AnimataP5 sketch on a different port than is used here.
  end
  
  def debuggery *args
    warn "* # * # * # * # * # *     MidiListener#debugery has #{args.pretty_inspect}"
  end

  def tweak_noise note_name, addr_pattern, effect
    trigger = 30
    mod = @event_tracker[note_name] % trigger
    new_val = if mod > trigger - 10
                0.9
              else
                0.3
              end

    Thread.new do
      @runner.execute_command "#{addr_pattern} #{effect} #{new_val}", :skip_appending
    end
  end


  def tweak_hh note_name, addr_pattern, effect, mod_value

    return if @event_tracker[note_name].to_i <  mod_value.to_i

    new_val = if @event_tracker[note_name] %  mod_value.to_i  < 5
                0.99
              else
                0.5
              end

    Thread.new do
      @runner.execute_command "#{addr_pattern} #{effect} #{new_val}", :skip_appending
    end
  end


  def wrap_up note_name, max_value
    warn "#{'*'*180}"
    warn "#{'*'*180}"
    warn "@event_tracker[note_name].to_i  = #{@event_tracker[note_name].to_i } : max_value.to_i = #{max_value.to_i}"
    warn "#{'*'*180}"
    warn "#{'*'*180}"

    if @event_tracker[note_name].to_i == max_value.to_i

      @runner.append_command "5"
      @runner.execute_command ":loop_off"
      @runner.append_command   ":interpolate1||/renoise/song/track/10/device/1/set_parameter_by_name Volume||0.7||0.0||8"
      @runner.append_command "20"
      @runner.append_command   "/renoise/transport/stop"
      @runner.append_command   "5"
    end
  end

  ########################################################################################
  def swap_tracks note_name, mod_value, track1, track2

    mod_value = if @last_mute.to_i < @unmute.to_i
                  mod_value.to_i / 4
                else
                  mod_value.to_i
                end


    warn "\n\n\n\n#{'?'*120}\n .................... swap_tracks ! mod_value = #{mod_value} ......... #{@event_tracker[note_name].to_i} ........  #{note_name}, #{mod_value}, #{track1}, #{track2}!" 

    return unless @event_tracker[note_name].to_i > 1

    warn "\n ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ \n\n ^^^^^^^^^^^^^^^^^^^^^ \nDO THE SWAP!   #{@event_tracker[note_name].to_i} % #{mod_value.to_i}  = #{@event_tracker[note_name].to_i % mod_value.to_i}"
    if (@event_tracker[note_name].to_i % mod_value.to_i) == 0

      if @last_mute == track1
        @last_mute = track2
        @unmute   = track1
      else
        @last_mute = track1
        @unmute    = track2
      end

      warn "last_mute = #{@last_mute}, @unmute = #{@unmute}"

      Thread.new do
        @runner.execute_command "/renoise/song/track/#{@last_mute}/mute", :skip_appending
        @runner.execute_command "/renoise/song/track/#{@unmute}/unmute",  :skip_appending
      end

    end

  end

  def play_lead *args
       @osc_client_p5 ||= Client.new '127.0.0.1', 8006 # HACK FIXME so that sht is not hard-coded.

    if @note1
      @runner.execute_command "/renoise/trigger/note_off  #{@lead_intr} 8 #{@note1} ", :skip_appending
    end

    if @note2
      @runner.execute_command "/renoise/trigger/note_off  #{@lead_intr} 8 #{@note2} ", :skip_appending
    end

    @lead_intr = if @last_mute.to_i < @unmute.to_i
                   9
                 else
                   8
                 end

    vol = if @lead_intr == 9
            50
          else
            100
          end

    @note1 = 40 + (rand 12)
    @note2 = @note1.to_i  

    while @note2 == @note1
      @note2 = 62 + (rand 12)
    end

    Thread.new do
      

# How do we send this to yet another OSC server?  The scripter only knows about Renoise OSC server.
      # Short plan: Have this particular script have it's own SC server.
      # Long plan: Consider having osc-scripter talk to multiple OSC servers, perhaps keyed by addr_pattern
      # OR: Tell osc-scripter to load a (reusable) file that will provide this extra OSC-sending power
      # along wth methods of for handling this so that you can use `execute_command`  and not
      # have helper files lke this know too much about how things interactions work
     msg = OSC::Message.new "/landscape/renderLeadTones", @note1, @note2
           t = Thread.new do
          begin
            @osc_client_p5.send msg
          rescue 
            warn '!'*80
            warn "Error sending OSC message #{msg.inspect}: #{$!}"
            warn "@client = #{@client.inspect}"
            warn '!'*80
          end
        end
    end

          @runner.execute_command "/renoise/trigger/note_on  #{@lead_intr} 8 #{@note1} #{vol}", :skip_appending
      @runner.execute_command "/renoise/trigger/note_on  #{@lead_intr} 8 #{@note2} #{vol}", :skip_appending
  end

end
