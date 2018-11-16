require 'dry-configurable'

module Voom
  module MessageBus
    extend Dry::Configurable
    setting :channels, []
    setting :source, :api
  end
end
