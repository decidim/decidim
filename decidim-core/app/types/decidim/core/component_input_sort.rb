# frozen_string_literal: true

module Decidim
  module Core
    class ComponentInputSort < BaseInputSort
      include HasPublishableInputSort

      graphql_name "ComponentSort"
      description "A type used for sorting any generic component"

      argument :id, String, "Sort by ID, valid values are ASC or DESC", required: false
    end
  end
end
