# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ProjectAttributes"
      description "Attributes for a project"

      argument :address, GraphQL::Types::String, "Address of this project", required: false
      argument :budget_amount, GraphQL::Types::BigInt, "The budget amount of this project", required: false
      argument :description, GraphQL::Types::JSON, description: "The description of this project", required: false
      argument :latitude, GraphQL::Types::Float, "Latitude of this project", required: false
      argument :longitude, GraphQL::Types::Float, "Longitude of this project", required: false
      argument :proposal_ids, [GraphQL::Types::Int], description: "The linked proposal IDs of this project", required: false
      argument :taxonomies, [GraphQL::Types::ID], description: "Taxonomies of this project", required: false
      argument :title, GraphQL::Types::JSON, description: "Title of this project", required: false
    end
  end
end
