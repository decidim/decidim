require_dependency "decidim/features/settings_manifest"

# frozen_string_literal: true
module Decidim
  # This class handles all the logic associated to configuring a feature
  # associated to a participatory process.
  #
  # It's normally not used directly but through the API exposed through
  # `Decidim.register_feature`.
  class FeatureManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :admin_engine, Rails::Engine
    attribute :engine, Rails::Engine

    attribute :name, Symbol
    attribute :hooks, Hash[Symbol => Array[Proc]], default: {}

    # A String with the feature's icon. The icon must be stored in the
    # engine's assets path.
    attribute :icon, String

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

    # Public: A block that gets called when seeding for this feature takes place.
    #
    # Returns nothing.
    def seeds(&block)
      @seeds = block
    end

    # Public: Creates the seeds for this features in order to populate the database.
    #
    # Returns nothing.
    def seed!
      @seeds&.call
    end

    # Public: Adds configurable attributes for this feature, scoped to a name. It
    # uses the DSL specified under `Decidim::FeatureSettingsManifest`.
    #
    # name - Either `global` or `step`
    # &block - The DSL present on `Decidim::FeatureSettingsManifest`
    #
    # Examples:
    #
    #   feature.settings(:global) do |settings|
    #     settings.attribute :voting_enabled, type: :boolean, default: true
    #   end
    #
    # Returns nothing.
    def settings(name = :global, &block)
      @settings ||= {}
      name = name.to_sym
      settings = (@settings[name] ||= FeatureSettingsManifest.new)
      yield(settings) if block
      settings
    end
  end
end
