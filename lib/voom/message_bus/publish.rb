require_relative 'settings'
# Use this class to publish events
# To setup a new channel add or change the initializer:
#
# Voom::MessageBus.configure do |config|
#   config.source = :source1
#   config.channels <<  { name: 'channel1',
#                         queue: 'channel1',
#                         worker: 'Voom::Workers::EventProcessor',
#                         exclude_envs: [:test]}
# end
#
# Then in your code:
# Voom::MessageBus::Publisher.publish(:event_name, {your_data: 'goes here'}) # sends to all channels
# Voom::MessageBus::Publisher.publish(:event_name, {your_data: 'goes here'}, channel: :channel1) # sends to a single channel
# Voom::MessageBus::Publisher.publish(:event_name, {your_data: 'goes here'}, channel: [:channel1, :channel2]) # sends to multiple channels
#
module Voom
  module MessageBus
    module Publisher
      class << self
        def channels_to_publish_to(channel)
          Voom::MessageBus.config.channels.select {|c| channel == :all || Array(channel).include?(c.fetch(:name).to_sym)}
        end

        def publish(event, payload, channel: :all)
          channels = channels_to_publish_to(channel)
          raise StandardError, 'Channel specified does not exist! Check your channel configuration.' if channels.empty?
          channels.each do |c|
            next if c.fetch(:exclude_envs) {[:test]}.include?(Rails.env.to_sym)
            Sidekiq::Client.push("class" => c.fetch(:worker),
                                 "queue" => c.fetch(:queue),
                                 "args" => [Event.new(event, payload).to_h])
          end
        end
      end

      class Event
        attr_reader :event, :payload

        def initialize(event, payload)
          @event = event
          @payload = payload
        end

        def to_h
          {event: event,
           payload: payload,
           source: Voom::MessageBus.config.source}
        end
      end
    end
  end
end
