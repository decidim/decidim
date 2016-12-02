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

    attribute :graphql_type

    validates :name, presence: true

    # Public: Registers a hook to this manifest. Hooks get fired when some
    # lifecycle events happen, like the creation of a component or its
    # destruction.
    #
    # event_name - A String or Symbol with the event name.
    # &block     - The block to run when the hook gets triggered.
    #
    # Returns nothing.
    def on(event_name, &block)
      hooks[event_name.to_sym] ||= []
      hooks[event_name.to_sym] << block
    end

    # Public: Runs all the hooks associated with this manifest and a particular
    # event.
    #
    # event_name - A String or Symbol with the event name.
    # context    - An optional context that will be provided to the block as a
    #              parameter. Usually the subject of the hook, mostly the
    #              Component.
    #
    # Returns nothing.
    def run_hooks(event_name, context = nil)
      return unless hooks[event_name]
      hooks[event_name.to_sym].each do |hook|
        hook.call(context)
      end
    end

    # Semiprivate: Resets all the hooks of this manifest. Mostly useful when
    # testing.
    #
    # Returns nothing.
    def reset_hooks!
      self.hooks = {}
    end
  end
end
