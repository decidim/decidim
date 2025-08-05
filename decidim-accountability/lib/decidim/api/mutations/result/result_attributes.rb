# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ResultAttributes"
      description "Attributes of a result"

      argument :decidim_accountability_status_id, GraphQL::Types::Int, description: "The status id for this result", required: false
      argument :description, GraphQL::Types::JSON, description: "The description for this result", required: false
      argument :end_date, GraphQL::Types::String, description: "The end date for this result(in 'dd-mm-yyyy' format)", required: false
      argument :external_id, GraphQL::Types::String, "The external ID for this result", required: false
      argument :parent_id, GraphQL::Types::Int, "The parent id of result", required: false
      argument :progress, GraphQL::Types::Float, description: "The progress for this result", required: false
      argument :project_ids, [GraphQL::Types::Int], description: "The linked proposal IDs for the result", required: false
      argument :proposal_ids, [GraphQL::Types::Int], description: "The linked proposal IDs for the result", required: false
      argument :start_date, GraphQL::Types::String, description: "The start date for this result(in 'dd-mm-yyyy' format)", required: false
      argument :taxonomies, [GraphQL::Types::Int], description: "Taxonomies of the result", required: false
      argument :title, GraphQL::Types::JSON, description: "The title for this result", required: false
      argument :weight, GraphQL::Types::Int, "The order of this result", required: false
    end
  end
end
