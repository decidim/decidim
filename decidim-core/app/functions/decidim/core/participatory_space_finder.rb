# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for a single participatory spaces
    # This can be easily overwritten by the participatory_space_manifest.query_finder
    class ParticipatorySpaceFinder < GraphQL::Function
      attr_reader :manifest, :model_class

      def initialize(manifest:)
        @manifest = manifest
        @model_class = manifest.model_class_name.constantize
      end

      argument :id, !types.ID, "The ID of the participatory space"

      def call(_obj, args, ctx)
        model_class.public_spaces.find_by(
          organization: ctx[:current_organization],
          id: args[:id]
        )
      end
    end
  end
end
