# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceInputSort < BaseInputSort
      include HasPublishableInputSort

      graphql_name "ParticipatorySpaceSort"
      description "A type used for sorting any object with published_at, created_at, updated_at fields"

      argument :id, ID, "Sort by ID, valid values are ASC or DESC", required: false
    end
  end
end
