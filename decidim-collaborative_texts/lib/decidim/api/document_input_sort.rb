# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class DocumentInputSort < Decidim::Core::BaseInputSort
      include Decidim::Core::HasTimestampInputSort

      graphql_name "CollaborativeTextSort"
      description "A type used for sorting blog collaborative texts"

      argument :id, GraphQL::Types::String, "Sort by ID, valid values are ASC or DESC", required: false
    end
  end
end
