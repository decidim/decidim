# frozen_string_literal: true

module Decidim
  module Core
    class CategoryInputFilter < BaseInputFilter
      graphql_name "CategoryFilter"
      description "A type used for filtering any category objects"

      argument :parent_id,
               type: [ID, { null: true }],
               description: "Returns the sub-categories for the given parent category or top-level categories if set to `null`",
               required: false,
               prepare: :prepare_parent_id

      def self.prepare_parent_id(parent_id, _ctx)
        { parent_id: }
      end
    end
  end
end
