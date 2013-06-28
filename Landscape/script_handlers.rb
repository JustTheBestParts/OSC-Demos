def layer_burst address, thread=false
    r1 = rand 0.2
    send_osc  "#{address} 1.0"
    sleep r1
    send_osc "#{address} 0.0"
    _ = rand( 10 ) + 10
    warn "+ + + + + + + + +   layer_burst  should be sleeping for #{_} seconds + + + + + + + + +   "
   sleep _
   " = = = = = = = layer_burst  should have slept for #{_} seconds  = = = =  ="
end
