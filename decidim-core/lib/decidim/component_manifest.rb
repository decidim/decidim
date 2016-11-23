# frozen_string_literal: true
module Decidim
  # This class handles all the logic associated to configuring a component
  # associated to a feature, so it can be included in a participatory process'
  # step.
  #
  # It's normally not used directly but through the API exposed through
  # `Decidim.register_feature`.
  class ComponentManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :engine, Rails::Engine
    attribute :admin_engine, Rails::Engine
    attribute :hooks, Hash[Symbol => Array[Proc]], default: {}

    validates :name, presence: true

    def on(event_name, &block)
      hooks[event_name.to_sym] ||= []
      hooks[event_name.to_sym] << block
    end

    def run_hooks(event_name, context = nil)
      return unless hooks[event_name]
      hooks[event_name.to_sym].each do |hook|
        hook.call(context)
      end
    end

    def reset_hooks!
      self.hooks = {}
    end
  end
end
