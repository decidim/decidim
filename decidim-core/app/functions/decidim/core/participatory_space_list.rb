# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for listing participatory spaces
    # This can be easily overwritten by the participatory_space_manifest.query_list
    # + info:
    # https://github.com/rmosolgo/graphql-ruby/blob/v1.6.8/guides/fields/function.md
    class ParticipatorySpaceList < GraphQL::Function
      attr_reader :manifest, :model_class

      def initialize(manifest:)
        @manifest = manifest
        @model_class = manifest.model_class_name.constantize
      end

      argument :order, Decidim::Core::ParticipatorySpaceInputSort, "This argument let's you order the results"

      def call(_obj, args, ctx)
        model_class.public_spaces.where(
          organization: ctx[:current_organization]
        ).order(create_order_keys(args[:order]))
      end

      private

      def create_order_keys(order_input)
        return {} unless order_input.respond_to? :map

        order_input.map do |key, value|
          [key.underscore, value.upcase]
        end.to_h
      end
    end
  end
end
