# frozen_string_literal: true
require_dependency "decidim/features/settings_manifest"
require_dependency "decidim/features/export_manifest"

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

    # A path with the `scss` stylesheet this engine provides. It is used to
    # mix this engine's stylesheets with the main app's stylesheets so it can
    # use the scss variables and mixins provided by Decidim::Core.
    attribute :stylesheet, String, default: nil

    # A String with the feature's icon. The icon must be stored in the
    # engine's assets path.
    attribute :icon, String

    # Actions are used to validate permissions of a feature against particular
    # authorizations or potentially other authorization rules.
    #
    # An example would be `vote` on participatory processes, or `create_meeting`
    # on meetings.
    #
    # A Feature can expose as many actions as it wants and the admin panel will
    # generate a UI to handle them. There's a set of controller helpers available
    # as well that allows checking for those permissions.
    attribute :actions, Array[String]

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

    # Public: Registers a resource inside a feature manifest. Exposes a DSL
    # defined by `Decidim::ResourceManifest`.
    #
    # Resource manifests are a way to expose a resource from one engine to
    # the whole system. This was resoruces can be linked between them.
    #
    # block - A Block that will be called to set the Resource attributes.
    #
    # Returns nothing.
    def register_resource
      manifest = ResourceManifest.new
      manifest.feature_manifest = self
      yield(manifest)
      manifest.validate!
      resource_manifests << manifest
    end

    def exports(name, &block)
      @exports ||= []
      @exports << [name, block]
      @export_manifests = nil
    end

    def export_manifests
      @export_manifests ||= @exports.map do |(name, block)|
        Decidim::Features::ExportManifest.new(name).tap do |manifest|
          block.call(manifest)
        end
      end
    end

    # Public: Finds all the registered resource manifest's via the
    # `register_resource` method.
    #
    # Returns an Array[ResourceManifest].
    def resource_manifests
      @resource_manifests ||= []
    end

    # Public: Stores an instance of StatsRegistry
    def stats
      @stats ||= StatsRegistry.new
    end

    # Public: Registers a stat inside a feature manifest.
    #
    # name - The name of the stat
    # options - A hash of options
    #         * primary: Wether the stat is primary or not.
    #         * priority: The priority of the stat used for render issues.
    # block - A block that receive the features to filter out the stat.
    #
    # Returns nothing.
    def register_stat(name, options = {}, &block)
      stats.register(name, options, &block)
    end
  end
end
