module Decidim
  class ComponentManifest
    attr_reader :name
    attr_accessor :engine, :admin_engine

    def initialize(name)
      @name = name.to_sym
      @hooks = {}
    end

    def on(event_name, &block)
      @hooks[event_name] ||= []
      @hooks[event_name] << block
    end

    def run_hooks(event_name, context)
      return unless @hooks[event_name]
      @hooks[event_name].each do |hook|
        hook.call(context)
      end
    end

    def reset_hooks!
      @hooks = {}
    end
  end
end
