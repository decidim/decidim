# frozen_string_literal: true

module Rectify
  class Presenter
    def method_missing(method_name, ...)
      if view_context.respond_to?(method_name)
        view_context.send(method_name, ...)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      view_context.respond_to?(method_name, include_private)
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

    def respond_to_missing?(method_name, include_private = false)
      @caller.respond_to?(method_name, include_private)
    end
  end
end
