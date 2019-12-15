# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for listing participatory spaces
    # This can be easily overwritten by the participatory_space_manifest.query_list
    # + info:
    # https://github.com/rmosolgo/graphql-ruby/blob/v1.6.8/guides/fields/function.md
    class ParticipatorySpaceListBase < GraphQL::Function
      include NeedsFilterAndOrder
      attr_reader :manifest, :model_class

      def initialize(manifest:)
        @manifest = manifest
        @model_class = manifest.model_class_name.constantize
      end

      def call(_obj, args, ctx)
        @query = model_class.public_spaces.where(
          organization: ctx[:current_organization]
        )

        add_filter_keys(args[:filter])
        add_order_keys(args[:order].to_h)
        @query
      end
    end
  end
end
