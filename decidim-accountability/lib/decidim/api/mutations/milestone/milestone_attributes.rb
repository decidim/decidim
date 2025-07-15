# frozen_string_literal: true

module Decidim
  module Accountability
    class MilestoneAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "MilestoneAttributes"
      description "Attributes of a milestone"

      argument :description, GraphQL::Types::JSON, description: "The description for this milestone", required: false
      argument :entry_date, GraphQL::Types::String, description: "Entry date for this milestone", required: false
      argument :title, GraphQL::Types::JSON, description: "Title for this milestone", required: false
    end
  end
end
