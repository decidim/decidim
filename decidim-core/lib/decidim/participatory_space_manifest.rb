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
  end
end
