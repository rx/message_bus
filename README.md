# Voom::MessageBus

A lightweight micro-service message bus based on top of Sidekiq.

Inspired by the blog post [SIDEKIQ AS A MICROSERVICE MESSAGE QUEUE](https://brandonhilkert.com/blog/sidekiq-as-a-microservice-message-queue/) by [Brandon Hilkert](https://github.com/brandonhilkert)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voom-message_bus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install voom-message_bus

### Microservice Pattern
Assuming you have a single `app` and `service` that you want to send messages back and forth between.

##### App
###### Recieving Messages
Add a worker to process messages from the service on the service message bus queue.   
    
    class ServiceWorker < Voom::Workers::EventProcessor
      sidekiq_options queue: :service-message-bus
    end

###### Publishing Messages
Add an initializer for publishing message to the service

    Voom::MessageBus.configure do |config|
      config.source = :app
      config.channels <<  { name: 'app',
                            queue: 'app-message-bus',
                            worker: 'AppWorker',
                            exclude_envs: [:test]}
    end

###### Sidekiq
Startup sidekiq listening to the service queue
    
    bundle exec sidekiq -q service-message-bus -q default    

##### Service

###### Recieving Messages
Add a worker to process messages from the service on the service message bus queue.   
    
    class AppWorker < Voom::Workers::EventProcessor
      sidekiq_options queue: :app-message-bus
    end

###### Publishing Messages
Add an initializer for publishing message to the service

    Voom::MessageBus.configure do |config|
      config.source = :service
      config.channels <<  { name: 'service',
                            queue: 'service-message-bus',
                            worker: 'ServiceWorker',
                            exclude_envs: [:test]}
    end

###### Sidekiq
Startup sidekiq listening to the app queue
    
    bundle exec sidekiq -q app-message-bus -q default    

## Usage
##### App

###### Publish Message
    Voom::MessageBus::Publisher.publish(:app_hello_world, {data: 'Hello from App'})
  
###### Recieve Message
    Voom::MessageBus::Subscribe.subscribe(:service_hello_world) do |payload|
      puts payload[:data]
    end


##### Service

###### Publish Message
    Voom::MessageBus::Publisher.publish(:service_hello_world, {data: 'Hello from Service'})

###### Recieve Message
    Voom::MessageBus::Subscribe.subscribe(:app_hello_world) do |payload|
      puts payload[:data]
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rx/message_bus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Voom::MessageBus project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rx/message_bus/blob/master/CODE_OF_CONDUCT.md).
