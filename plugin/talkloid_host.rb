# -*- coding: utf-8 -*-

Plugin.create :talkloid_host do

  on_talkloid_receive do |remote_event|
    # 接続されているクライアントに配信
    Plugin.call(:talkloid_emit, remote_event)
  end
  
end
