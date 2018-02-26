require "socket"
require "json"

Plugin.create :talkloid_transport_tcp do
  
  on_talkloid_start_host do
    @socket = TCPServer.open(3939)
    Thread.start do
      loop do
        Thread.start(@socket.accept) do |socket|
          while buf = socket.gets
            ev = JSON.load(buf.chomp)

            p ev
            Plugin.call(:talkloid_receive, ev["event"].to_sym, ev["args"])
          end
        end
      end
    end
    
    puts "Talkloid:TCP Host Mode"
  end

  on_talkloid_start_client do
    @socket = TCPSocket.open("127.0.0.1", 3939)

    puts "Talkloid:TCP Client Mode"
  end

  on_talkloid_emit do |event_name, args|
    if @socket.is_a? TCPServer
      # nothing to do
    else
      @socket.puts(JSON.dump({event: event_name, args: args}))
      @socket.flush
    end
  end

  on_unload do
    @socket&.close
  end
end
