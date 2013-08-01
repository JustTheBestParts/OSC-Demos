def win32?
  RUBY_PLATFORM =~ /w32/ ? true : false
end


def renoise_with_file song_file
  if win32?
    song_file.gsub! /\//, '\\'

    Thread.new { `call #{song_file}` }
  else
    Thread.new { `renoise #{song_file}` }
  end
  sleep 10
end



desc "Launch Renoise and execute the song-mixer script demo"
task 'song-mixer' do

  renoise_with_file "Renoise/osc-scripter-demo-song.xrns"

  Thread.new do 
    Dir.chdir 'Renoise' do
     `gnome-terminal -x osc-scripter song-mixer/song-mixer.oscr`
    end
  end

  sleep 5
end



task :default do
`rake -T`
end

