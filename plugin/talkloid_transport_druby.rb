# -*- coding: utf-8 -*-
require "drb/drb"

module Plugin::Talkloid
  class DRubyProxy
    attr_reader :name
    
    def initialize(plugin_instance)
      @name = Plugin::Talkloid.hostname
      @plugin_instance = plugin_instance
    end
    
    def clients
      @clients ||= {}
    end
    
    def register_client(drb_proxy)
      puts "DRubyProxy: register_client #{drb_proxy.name}"
      clients[drb_proxy.name] = drb_proxy
    end

    def unregister_client(name)
      puts "DRubyProxy: unregister_client #{name}"
      clients.delete(name)
    end
    
    def call(remote_event)
      puts "DRubyProxy: call"
      Plugin.call(:talkloid_receive, remote_event)
    end

    def filtering(remote_event)
      puts "DRubyProxy: filtering"
      # TODO: filteringって返さないといけないからめんどいね
    end

    def close_by_host
      puts "DRubyProxy: close_by_host"
      @plugin_instance.cleanup_client
    end
  end
end

Plugin.create :talkloid_transport_druby do

  on_talkloid_start_host do
    @host_proxy = Plugin::Talkloid::DRubyProxy.new(self)
    @server = DRb::DRbServer.new("druby://localhost:39390",
                                 @host_proxy,
                                 safe_level: 1)

    puts "Talkloid:DRb Host Mode : " + Plugin::Talkloid.hostname
  end

  on_talkloid_start_client do
    @client_proxy = Plugin::Talkloid::DRubyProxy.new(self)
    @server = DRb::DRbServer.new
    @remote = DRbObject.new_with_uri("druby://localhost:39390")
    @remote.register_client(@client_proxy)
    
    puts "Talkloid:DRb Client Mode : " + Plugin::Talkloid.hostname
  end

  on_talkloid_stop_host do
    cleanup_host
  end

  on_talkloid_stop_client do
    cleanup_client
  end

  on_talkloid_emit do |remote_event|
    unless @host_proxy.nil?
      puts "Talkloid:DRb Host -> Client"
      @host_proxy.clients.each do |name, client|
        begin
          client.call(remote_event)
        rescue DRb::DRbError => e
          puts "Talkloid:DRb Error in client. disconnect."
          puts e

          @host_proxy.clients.delete(name)
        end
      end
    end
    unless @client_proxy.nil?
      puts "Talkloid:DRb Client -> Host"
      begin
        @remote.call(remote_event)
      rescue DRb::DRbError => e
        puts "Talkloid:DRb Error in host. disconnect."
        puts e

        @client_proxy = nil
        @remote = nil
      end
    end
  end

  def cleanup_host
    unless @host_proxy.nil?
      @host_proxy.clients.each do |name, client|
        begin
          client.close_by_host
        rescue DRb::DRbError => e
          puts "Talkloid:DRb Error in client. disconnect."
          puts e
        end
      end
      @host_proxy = nil
    end

    @server&.stop_server
    @server = nil
  end

  def cleanup_client
    unless @remote.nil?
      begin
        @remote.unregister_client(@client_proxy.name)
      rescue DRb::DRbError => e
        puts "Talkloid:DRb Error in host. disconnect."
        puts e
      end
      @client_proxy = nil
      @remote = nil
    end

    @server&.stop_server
    @server = nil
  end

  on_unload do
    cleanup_host
    cleanup_client
  end
  
end
