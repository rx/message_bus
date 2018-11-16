require_relative 'settings'
# Use this class to subscribe to events #
# Add an initializer:
# Voom::MessageBus::Subscribe.subscribe(:event_name) do
# end
#
module Voom
  module MessageBus
    module Subscribe
      class << self
        attr_reader :subscriptions

        def subscribe(event, source: :all, processor: nil, &block)
          raise StandardError, 'Must pass either a processor class that responds to call or a block' unless (processor == nil) ^ (block == nil)
          @subscriptions ||= Concurrent::Array.new
          @subscriptions << Subscription.new(source, event, processor || block)
        end
      end

      class Subscription
        attr_reader :source, :event_name, :processor

        def initialize(source, event_name, processor)
          @source = source
          @event_name = event_name
          @processor = processor
        end
      end
    end
  end
end
