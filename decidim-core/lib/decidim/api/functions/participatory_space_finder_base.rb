# frozen_string_literal: true

module Decidim
  module Core
    # An abstract base class resolver for the GraphQL endpoint for a single participatory space
    # Inherit from this class and add search arguments to create finder participatory classes
    # as is shown in ParticipatorySpaceFinder
    class ParticipatorySpaceFinderBase
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
        args.compact.keys.each do |key|
          query[key] = args[key]
        end
        model_class.public_spaces.find_by(query)
      end
    end
  end
end
