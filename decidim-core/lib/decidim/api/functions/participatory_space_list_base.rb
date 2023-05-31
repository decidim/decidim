# frozen_string_literal: true

module Decidim
  module Core
    # An abstract base class resolver for the GraphQL endpoint for listing participatory spaces
    # Inherit from this class and add search arguments to create list-finders participatory classes
    # as is shown in ParticipatorySpaceList
    # + info:
    # https://github.com/rmosolgo/graphql-ruby/blob/v1.6.8/guides/fields/function.md
    class ParticipatorySpaceListBase
      include NeedsApiFilterAndOrder
      include NeedsApiDefaultOrder
      attr_reader :manifest

      def initialize(manifest:)
        @manifest = manifest
      end

      # lazy instantation of the class
      def model_class
        @model_class ||= manifest.model_class_name.constantize
      end

      def call(_obj, args, ctx)
        base_query = model_class.where(
          organization: ctx[:current_organization]
        )

        @query =
          if ctx[:current_user]&.admin?
            base_query
          elsif base_query.respond_to?(:visible_for)
            base_query.visible_for(ctx[:current_user])
          else
            base_query.public_spaces
          end

        add_filter_keys(args[:filter])
        add_order_keys(args[:order].to_h)
        add_default_order
        @query
      end
    end
  end
end
