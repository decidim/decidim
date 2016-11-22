require "decidim/configuration"

module Decidim
  class ComponentManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :engine, Rails::Engine
    attribute :admin_engine, Rails::Engine
    attribute :hooks, Hash[Symbol => Array[Proc]], default: {}

    validates :name, presence: true

    def configuration
      @configuration ||= Configuration.new
      yield(@configuration) if block_given?
      @configuration
    end

    def on(event_name, &block)
      hooks[event_name.to_sym] ||= []
      hooks[event_name.to_sym] << block
    end

    def run_hooks(event_name, context)
      return unless hooks[event_name]
      hooks[event_name.to_sym].each do |hook|
        hook.call(context)
      end
    end
  end
end
