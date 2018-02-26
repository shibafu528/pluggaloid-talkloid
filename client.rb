# -*- coding: utf-8 -*-
require 'bundler/setup'
Bundler.require(:default)

include Pluggaloid
Delayer.default = Delayer.generate_class(priority: [:high, :normal, :low], default: :normal)

require_relative 'plugin/talkloid.rb'
require_relative 'plugin/talkloid_transport_druby.rb'

Plugin.create :sample do
  on_yukari do |msg|
    puts "on_yukari : #{ msg }"
  end
end

Plugin.call(:talkloid_start_client)

# Pluggaloid main loop
while true
  Plugin.call(:miku, "ミクだよ (#{Time.now})")
  Delayer.run
  sleep 0.05
end
