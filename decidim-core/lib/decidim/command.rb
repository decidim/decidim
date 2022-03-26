# frozen_string_literal: true

# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/command.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
module Decidim
  class Command
    include Wisper::Publisher

    def self.call(*args, &block)
      event_recorder = Decidim::EventRecorder.new

      command = new(*args)
      command.subscribe(event_recorder)
      command.evaluate(&block) if block_given?
      command.call

      event_recorder.events
    end

    def evaluate(&block)
      @caller = eval("self", block.binding, __FILE__, __LINE__)
      instance_eval(&block)
    end

    def transaction(&block)
      ActiveRecord::Base.transaction(&block) if block_given?
    end

    def method_missing(method_name, *args, &block)
      if @caller.respond_to?(method_name, true)
        @caller.send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @caller.respond_to?(method_name, include_private)
    end
  end
end
