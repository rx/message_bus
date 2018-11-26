require 'sidekiq/worker'

# When an event is fired
# This dispatches the events to the appropriate subscribers
# See Voom::MessageBus::Subscribe for how to subscribe to an event.
module Voom
  module Workers
    class EventProcessor
      # include Logging::Tracing
      include Sidekiq::Worker

      def perform(*args)
        event = args.first
        # trace {event.inspect}
        event_name = event.fetch('event')
        event_source = event.fetch('source')
        payload = event.fetch('payload')
        # trace {"Call perform with event(#{event_name}) payload(#{payload})"}

        (Voom::MessageBus::Subscribe.subscriptions || []).each do |s|
          next unless (s.source.to_sym == :all || s.source.to_s == event_source) &&
              (s.event_name.to_sym == :all || s.event_name.to_s == event_name)
          # trace {"Calling processor: #{s.processor.inspect}, with event(#{event_name}) payload(#{payload})"}
          s.processor.call(payload, event_name)
        end
      end
    end
  end
end
