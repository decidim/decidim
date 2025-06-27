# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ProjectAttributes"
      description "Attributes for a project"

      argument :budget_amount, GraphQL::Types::Int, description: "The budget amount of the project (maximum)", required: true
      argument :budget_amount_min, GraphQL::Types::Int, description: "The minimum budget amount of the project", required: false
      argument :budget_id, GraphQL::Types::ID, description: "The project budget ID", required: false
      argument :description, GraphQL::Types::JSON, description: "The project description localized hash (HTML), e.g. {\"en\": \"<p>English description</p>\"}", required: true
      argument :title, GraphQL::Types::JSON, description: "The project title localized hash, e.g. {\"en\": \"English title\"}", required: true

      argument :category_id, GraphQL::Types::Int, description: "The project category ID", required: false
      argument :scope_id, GraphQL::Types::Int, description: "The project scope ID", required: false

      argument :location, ProjectLocationAttributes, "The project location", required: false

      argument :main_image, Decidim::Apifiles::FileAttributes, "The main image for the project", required: false

      # Linked resources
      argument :idea_ids, [GraphQL::Types::Int], description: "The linked idea IDs for the project", required: false
      argument :plan_ids, [GraphQL::Types::Int], description: "The linked plan IDs for the project", required: false
      argument :proposal_ids, [GraphQL::Types::Int], description: "The linked proposal IDs for the project", required: false

      def main_image_attributes
        return unless main_image
        return { remove_main_image: true } if main_image.remove

        { main_image: main_image.blob } if main_image.blob
      end
    end
  end
end
