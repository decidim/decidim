# frozen_string_literal: true

require "decidim/settings_manifest"
require "decidim/participatory_space_context_manifest"
require "decidim/exporters/export_manifest"

module Decidim
  # This class handles all the logic associated to configuring a participatory
  # space, the highest level object of Decidim.
  #
  # It's normally not used directly but through the API exposed through
  # `Decidim.register_participatory_space`.
  class ParticipatorySpaceManifest
    include ActiveModel::Model
    include Decidim::AttributeObject::Model

    attribute :name, Symbol

    # The ActiveRecord class name of the model we're exposing
    attribute :model_class_name, String

    # The name of the named Rails route to create the url to the resource.
    # When not explicitly set, it will use the model name.
    attribute :route_name, String

    attribute :query_type, String, default: "Decidim::Core::ParticipatorySpaceType"
    attribute :query_finder, String, default: "Decidim::Core::ParticipatorySpaceFinder"
    attribute :query_list, String, default: "Decidim::Core::ParticipatorySpaceList"

    # An array with the name of the classes that will be exported with
    # the download your data feature for this component. For example, `Decidim::<MyModule>::<MyClass>``
    attribute :data_portable_entities, Array, default: []

    # A String with the component's icon. The icon must be stored in the
    # engine's assets path.
    attribute :icon, String

    # The name of the class that handles the permissions for this space. It will
    # probably have the form of `Decidim::<MySpace>::Permissions`.
    attribute :permissions_class_name, String, default: "Decidim::DefaultPermissions"

    # The cell path to use to render the card of a resource.
    attribute :card, String

    # A path with the `scss` stylesheet this engine provides. It is used to
    # mix this engine's stylesheets with the main app's stylesheets so it can
    # use the scss variables and mixins provided by Decidim::Core.
    attribute :stylesheet, String, default: nil

    # A callback that will be executed when an account is destroyed.
    # The Proc will receive the `user` that's being destroyed.
    attribute :on_destroy_account, Proc, default: nil

    validates :name, presence: true

    # A context used to set the layout and behavior of a participatory space. Full documentation can
    # be found looking at the `ParticipatorySpaceContextManifest` class.
    #
    # Example:
    #
    #     context(:public) do |context|
    #       context.layout "layouts/decidim/some_layout"
    #     end
    #
    #     context(:public).layout
    #     # => "layouts/decidim/some_layout"
    #
    # Returns Nothing.
    def context(name = :public, &block)
      name = name.to_sym
      @contexts ||= {}

      if block
        context = ParticipatorySpaceContextManifest.new
        context.instance_eval(&block)
        @contexts[name] = context
      end

      @contexts.fetch(name)
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
    def seed!
      print "Creating seeds for the #{name} space...\n" unless Rails.env.test?
      @seeds&.call
    end

    # The name of the named Rails route to create the url to the resource.
    #
    # Returns a String.
    def route_name
      super || model_class_name.demodulize.underscore
    end

    # Public: A block that retrieves all the participatory spaces for the manifest.
    # The block receives a `Decidim::Organization` as a parameter in order to filter.
    # The block is expected to return an `ActiveRecord::Association`.
    #
    # Returns nothing.
    def participatory_spaces(&block)
      @participatory_spaces ||= block
    end

    # Public: Finds the permission class from its name, using the
    # `permissions_class_name` attribute. If the class does not exist,
    # it raises an exception. If the class name is not set, it returns nil.
    #
    # Returns a Class.
    def permissions_class
      permissions_class_name&.constantize
    end

    # Public: Stores an instance of StatsRegistry
    def stats
      @stats ||= StatsRegistry.new
    end

    # Public: Registers a stat inside a participatory_space manifest.
    #
    # name - The name of the stat
    # options - A hash of options
    #         * primary: Whether the stat is primary or not.
    #         * priority: The priority of the stat used for render issues.
    # block - A block that receive the components to filter out the stat.
    #
    # Returns nothing.
    def register_stat(name, options = {}, &)
      stats.register(name, options, &)
    end

    # Public: Registers a resource. Exposes a DSL defined by
    # `Decidim::ResourceManifest`.
    #
    # Resource manifests are a way to expose a resource from one engine to
    # the whole system. This way resources can be linked between them.
    #
    # name - A name for that resource. Should be singular (ie not plural).
    # block - A Block that will be called to set the Resource attributes.
    #
    # Returns nothing.
    def register_resource(name, &)
      Decidim.register_resource(name, &)
    end

    # Public: Registers an export artifact with a name and its properties
    # defined in `Decidim::Exporters::ExportManifest`.
    #
    # Export artifacts provide a unified way for processes to register
    # exportable collections serialized via a `Serializer` that eventually
    # are transformed to their formats.
    #
    # name  - The name of the artifact for this export. Should be unique in the
    # context of the space.
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
    # for this space.
    #
    # Returns an Array of <Decidim::Exporters::ExportManifest>.
    def export_manifests
      @export_manifests ||= Array(@exports).map do |(name, block)|
        Decidim::Exporters::ExportManifest.new(name, self).tap do |manifest|
          block.call(manifest)
        end
      end
    end

    # The block is a callback that will be invoked with the destroyed `user` as argument.
    def register_on_destroy_account(&block)
      @on_destroy_account = block
    end

    def invoke_on_destroy_account(user)
      return unless @on_destroy_account

      @on_destroy_account.call(user)
    end
  end
end
