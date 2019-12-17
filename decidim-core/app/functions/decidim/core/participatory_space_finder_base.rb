# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for a single participatory spaces
    # This can be easily overwritten by the participatory_space_manifest.query_finder
    class ParticipatorySpaceFinderBase < GraphQL::Function
      attr_reader :manifest

      def initialize(manifest:)
        @manifest = manifest
      end

      # lazy instantation of the class
      def model_class
        @model_class ||= manifest.model_class_name.constantize
      end

      def call(_obj, args, ctx)
        query = { organization: ctx[:current_organization] }
        args.keys.each do |key|
          query[key] = args[key]
        end
        model_class.public_spaces.find_by(query)
      end
    end
  end
end
