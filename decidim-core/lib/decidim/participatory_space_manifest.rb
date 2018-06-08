# frozen_string_literal: true

require "decidim/settings_manifest"
require "decidim/participatory_space_context_manifest"

module Decidim
  # This class handles all the logic associated to configuring a participatory
  # space, the highest level object of Decidim.
  #
  # It's normally not used directly but through the API exposed through
  # `Decidim.register_participatory_space`.
  class ParticipatorySpaceManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol

    # The ActiveRecord class name of the model we're exposing
    attribute :model_class_name, String

    # The name of the named Rails route to create the url to the resource.
    # When not explicitly set, it will use the model name.
    attribute :route_name, String

    attribute :query_type, String, default: "Decidim::Core::ParticipatorySpaceType"

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
    def register_resource(name, &block)
      Decidim.register_resource(name, &block)
    end
  end
end
