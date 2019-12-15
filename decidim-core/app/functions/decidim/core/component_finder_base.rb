# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for a single component
    class ComponentFinderBase < GraphQL::Function
      attr_reader :model_class

      def initialize(model_class:)
        @model_class = model_class
      end

      def call(component, args, _ctx)
        query = { component: component }
        args.keys.each do |key|
          query[key] = args[key]
        end
        model_class.published.find_by(query)
      end
    end
  end
end
