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

      # lazy instantiation of the class
      def model_class
        @model_class ||= manifest.model_class_name.constantize
      end

      def call(_obj, args, ctx)
        query = { organization: ctx[:current_organization] }
        args.compact.keys.each do |key|
          query[key] = args[key]
        end

        @query =
          if ctx[:current_user]&.admin?
            model_class
          elsif model_class.respond_to?(:visible_for)
            model_class.visible_for(ctx[:current_user])
          else
            model_class.public_spaces
          end

        @query.find_by(query)
      end
    end
  end
end
