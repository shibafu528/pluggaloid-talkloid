# -*- coding: utf-8 -*-
require "securerandom"

module Plugin::Talkloid
  RemoteEvent = Struct.new(:host, :kind, :event_name, :args)

  class << self
    def hostname
      if defined? CHIConfig
        @hostname ||= SecureRandom.uuid + "@" + `hostname`.chop + "_" + CHIConfig.NAME + "_" + CHIConfig.VERSION.to_s
      else
        @hostname ||= SecureRandom.uuid + "@" + `hostname`.chop
      end
    end
  end
end

#class Pluggaloid::Event
#  def call_all_listeners(args)
#    catch(:plugin_exit) do
#      @listeners.each do |listener|
#        listener.call(*args)
#      end
#      unless self.name =~ /\Atalkloid_/
#        vm.Plugin.call(:talkloid_hook_event, self.name, args)
#      end
#    end
#  end
#end

class Plugin
  class << self
    alias :_call :call
    def call(event_name, *args)
      _call(event_name, *args)
      _call(:talkloid_hook_event, event_name, args) unless event_name =~ /\Atalkloid_/
    end
  end
end

Plugin.create :talkloid do

  on_talkloid_hook_event do |event_name, args|
    puts "Talkloid Hook / :#{event_name}(#{args})"

    Plugin._call(:talkloid_emit, Plugin::Talkloid::RemoteEvent.new(Plugin::Talkloid.hostname, :event, event_name, args))
  end

  on_talkloid_receive do |remote_event|
    # 自身が発したイベントを実行してはいけない
    break if remote_event.host == Plugin::Talkloid.hostname
    
    puts "Talkloid Receive / #{remote_event.event_name} on #{remote_event.host}"

    Plugin._call(remote_event.event_name, *remote_event.args)
  end
end

=begin
2. クライアントのイベントコール
[C] Plugin.call
[C] talkloid_hook_event : イベントのフック
[C] talkloid_emit       : イベントをホストに送信
↓
[H] talkloid_receive    : イベントをクライアントから受信
[H] Plugin.call         : イベントを実行
[H] talkloid_emit       : イベントを他のクライアントに送信
↓
[C] talkloid_receive    : イベントを受信 (自分が発したイベントなら破棄)
[C] Plugin.call         : イベントを実行
=end
