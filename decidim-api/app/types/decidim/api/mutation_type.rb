# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root mutation type of the whole API
    class MutationType < GraphQL::Schema::Object
      graphql_name "Mutation"
      description "The root mutation of this schema"

      def self.define(&block)

      end
    end
  end
end
