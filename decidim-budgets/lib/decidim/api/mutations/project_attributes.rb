# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ProjectAttributes"
      description "Attributes for a project"

      argument :address, GraphQL::Types::String, "Address of this project", required: false
      argument :budget_amount, GraphQL::Types::Int, "The budget amount for this project", required: false
      argument :description, GraphQL::Types::JSON, description: "The project description", required: false
      argument :latitude, GraphQL::Types::Float, "Latitude of this projct", required: false
      argument :longitude, GraphQL::Types::Float, "Longitude of this project", required: false
      argument :proposal_ids, [GraphQL::Types::Int], description: "The linked proposal IDs for the project", required: false
      argument :taxonomies, [GraphQL::Types::Int], description: "Taxonomies of the project", required: false
      argument :title, GraphQL::Types::JSON, description: "The project title", required: false
    end
  end
end
