module Rectify
  class Presenter

    def method_missing(method_name, ...)
      if view_context.respond_to?(method_name)
        view_context.send(method_name, ...)
      else
        super
      end
    end
  end

  class Command
    def self.call(*args, **kwargs, &block)
      event_recorder = EventRecorder.new

      command = new(*args, **kwargs)
      command.subscribe(event_recorder)
      command.evaluate(&block) if block_given?
      command.call

      event_recorder.events
    end
    def method_missing(method_name, ...)
      if @caller.respond_to?(method_name, true)
        @caller.send(method_name, ...)
      else
        super
      end
    end
  end
end
