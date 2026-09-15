# frozen_string_literal: true

module Decidim
  module Accountability
    class MilestoneAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "MilestoneAttributes"
      description "Attributes for a milestone"

      argument :description, GraphQL::Types::JSON, description: "The description of this milestone", required: false
      argument :entry_date, GraphQL::Types::String, description: "Entry date of this milestone", required: false
      argument :title, GraphQL::Types::JSON, description: "Title of this milestone", required: false
    end
  end
end
