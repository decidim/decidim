# frozen_string_literal: true

require "decidim/settings_manifest"
require "decidim/exporters/export_manifest"
require "decidim/importers/import_manifest"

module Decidim
  # This class handles all the logic associated to configuring a component
  # associated to a participatory process.
  #
  # It's normally not used directly but through the API exposed through
  # `Decidim.register_component`.
  class ComponentManifest
    include ActiveModel::Model
    include Decidim::AttributeObject::Model

    attribute :admin_engine, Rails::Engine, **{}
    attribute :engine, Rails::Engine, **{}

    attribute :name, Symbol
    attribute(:hooks, { Symbol => Array[Proc] }, default: {})

    attribute :query_type, String, default: "Decidim::Core::ComponentType"

    # An array with the name of the classes that will be exported with
    # the download your data feature for this component. For example, `Decidim::<MyModule>::<MyClass>``
    attribute :data_portable_entities, Array, default: []

    # An array with the name of the classes to know the participants
    # of the component at the time of sending the newsletter. For example, `Decidim::<MyModule>::<MyClass>``
    attribute :newsletter_participant_entities, Array, default: []

    # A path with the `scss` stylesheet this engine provides. It is used to
    # mix this engine's stylesheets with the main app's stylesheets so it can
    # use the scss variables and mixins provided by Decidim::Core.
    attribute :stylesheet, String, default: nil

    # A path with the `scss` admin stylesheet this engine provides. It is used
    # to mix this engine's stylesheets with the main app's admin stylesheets so
    # it can use the scss variables and mixins provided by Decidim::Admin.
    attribute :admin_stylesheet, String, default: nil

    # A String with the component's icon. The icon must be stored in the
    # engine's assets path.
    attribute :icon, String

    # Actions are used to validate permissions of a component against particular
    # authorizations or potentially other authorization rules.
    #
    # An example would be `vote` on participatory processes, or `create_meeting`
    # on meetings.
    #
    # A Component can expose as many actions as it wants and the admin panel will
    # generate a UI to handle them. There's a set of controller helpers available
    # as well that allows checking for those permissions.
    attribute :actions, Array[String]

    # The name of the class that handles the permissions for this component. It will
    # probably have the form of `Decidim::<MyComponent>::Permissions`.
    attribute :permissions_class_name, String, default: "Decidim::DefaultPermissions"

    # The name of the class that handles extra logic on settings for this component.
    # Optional class, that if present receives the settings and validates them.
    # The suggested naming is `Decidim::<MyComponent>::Admin::ComponentForm`.
    attribute :component_form_class_name, String, default: "Decidim::Admin::ComponentForm"

    # Does this component have specific data to serialize and import?
    # Beyond the attributes in decidim_component table.
    attribute :serializes_specific_data, Boolean, default: false

    # The class to be used to serialize specific data for the current component.
    # Should be a kind of `Decidim::Exporters::Serializer`.
    #
    # Note that this class will be initialized with the component as argument.
    # Then it makes no sense to use the base Decidim::Exporters::Serializer because it
    # will serialize the component itself, not the specific data depending on it.
    # Thus you will always be setting a subclass of `Decidim::Exporters::Serializer`.
    #
    attribute :specific_data_serializer_class_name, String

    # The class to be used to import specific data for the current component.
    # Should be a kind of `Decidim::Importers::Importer`.
    #
    attribute :specific_data_importer_class_name, String

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
    #              parameter. Usually the subject of the hook.
    #
    # Returns nothing.
    def run_hooks(event_name, context = nil)
      return unless hooks[event_name]

      hooks[event_name.to_sym].map do |hook|
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

    # Public: A block that gets called when seeding for this component takes place.
    #
    # Returns nothing.
    def seeds(&block)
      @seeds = block
    end

    # Public: Creates the seeds for this components in order to populate the database.
    #
    # Returns nothing.
    def seed!(participatory_space)
      print "-- Creating #{name} component seeds for the participatory space with ID: #{participatory_space.id}...\n" unless Rails.env.test?
      @seeds&.call(participatory_space)
    end

    # Public: Adds configurable attributes for this component, scoped to a name. It
    # uses the DSL specified under `Decidim::SettingsManifest`.
    #
    # name - Either `global` or `step`
    # &block - The DSL present on `Decidim::SettingsManifest`
    #
    # Examples:
    #
    #   component.settings(:global) do |settings|
    #     settings.attribute :voting_enabled, type: :boolean, default: true
    #   end
    #
    # Returns nothing.
    def settings(name = :global, &block)
      @settings ||= {}
      name = name.to_sym
      settings = (@settings[name] ||= SettingsManifest.new)
      yield(settings) if block
      settings
    end

    # Public: Registers an export artifact with a name and its properties
    # defined in `Decidim::Exporters::ExportManifest`.
    #
    # Export artifacts provide an unified way for components to register
    # exportable collections serialized via a `Serializer` that eventually
    # are transformed to their formats.
    #
    # name  - The name of the artifact. Should be unique in the context of
    #         the component.
    # block - A block that receives the manifest as its only argument.
    #
    # Returns nothing.
    def exports(name, &block)
      return unless name

      @exports ||= []
      @exports << [name, block]
      @export_manifests = nil
    end

    # Pubic: Returns a collection of previously registered export manifests
    # for this component.
    #
    # Returns an Array<Decidim::Exporters::ExportManifest>.
    def export_manifests
      @export_manifests ||= Array(@exports).map do |(name, block)|
        Decidim::Exporters::ExportManifest.new(name, self).tap do |manifest|
          block.call(manifest)
        end
      end
    end

    def imports(name, &block)
      return unless name

      @imports ||= []
      @imports << [name, block]
      @import_manifests = nil
    end

    def import_manifests
      @import_manifests ||= Array(@imports).map do |(name, block)|
        Decidim::Importers::ImportManifest.new(name, self).tap do |manifest|
          block.call(manifest)
        end
      end
    end

    def serializes_specific_data?
      serializes_specific_data
    end

    # Public: Stores an instance of StatsRegistry
    def stats
      @stats ||= StatsRegistry.new
    end

    # Public: Registers a stat inside a component manifest.
    #
    # name - The name of the stat
    # options - A hash of options
    #         * primary: Whether the stat is primary or not.
    #         * priority: The priority of the stat used for render issues.
    # block - A block that receive the components to filter out the stat.
    #
    # Returns nothing.
    def register_stat(name, options = {}, &block)
      stats.register(name, options, &block)
    end

    # Public: Finds the permission class from its name, using the
    # `permissions_class_name` attribute. If the class does not exist,
    # it raises an exception. If the class name is not set, it returns nil.
    #
    # Returns a Class.
    def permissions_class
      permissions_class_name&.constantize
    end

    # Public: Finds the form class from its component, using the
    # `component_form_class_name` attribute. If the class does not exist,
    # it raises an exception. If the class name is not set, it returns nil.
    #
    # Returns a Class.
    def component_form_class
      component_form_class_name&.constantize
    end

    # Public: Finds the specific data serializer class from its name, using the
    # `specific_data_serializer_class_name` attribute. If the class does not exist,
    # it raises an exception. If the class name is not set, it returns nil.
    #
    # Returns a Decidim::Exporters::Serializer subclass or nil.
    def specific_data_serializer_class
      specific_data_serializer_class_name&.constantize
    end

    # Public: Finds the specific data importer class from its name, using the
    # `specific_data_importerer_class_name` attribute. If the class does not exist,
    # it raises an exception. If the class name is not set, it returns nil.
    #
    # Returns a Decidim::Importers::Importer subclass or nil.
    def specific_data_importer_class
      specific_data_importer_class_name&.constantize
    end

    # Public: Registers a resource. Exposes a DSL defined by
    # `Decidim::ResourceManifest`. Automatically sets the component manifest
    # for that resource to the current one.
    #
    # Resource manifests are a way to expose a resource from one engine to
    # the whole system. This way resources can be linked between them.
    #
    # name - A name for that resource. Should be singular (ie not plural).
    # block - A Block that will be called to set the Resource attributes.
    #
    # Returns nothing.
    def register_resource(name)
      my_component_manifest = self

      my_block = proc do |resource|
        resource.component_manifest = my_component_manifest
        yield(resource)
      end

      Decidim.register_resource(name, &my_block)
    end
  end
end
