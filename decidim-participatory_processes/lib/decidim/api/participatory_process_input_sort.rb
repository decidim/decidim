# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessInputSort < Decidim::Core::BaseInputSort
      include Decidim::Core::HasPublishableInputSort

      graphql_name "ParticipatoryProcessSort"
      description "A type used for sorting participatory processess"

      argument :id, GraphQL::Types::String, "Sort by ID, valid values are ASC or DESC", required: false
      argument :start_date, GraphQL::Types::String, "Sort by participatory process starting date, valid values are ASC or DESC", required: false
    end
  end
end
