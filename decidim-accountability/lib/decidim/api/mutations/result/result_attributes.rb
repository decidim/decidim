# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ResultAttributes"
      description "Attributes for a result"

      argument :decidim_accountability_status_id, GraphQL::Types::Int, description: "Status of the result", required: false
      argument :description, GraphQL::Types::JSON, description: "Description of the result", required: false
      argument :end_date, GraphQL::Types::String, description: "End date of this result(in 'dd-mm-yyyy' format)", required: false
      argument :external_id, GraphQL::Types::String, description: "External ID of this result", required: false
      argument :parent_id, GraphQL::Types::Int, description: "Parent id of the result", required: false
      argument :progress, GraphQL::Types::Float, description: "Progress of this result", required: false
      argument :project_ids, [GraphQL::Types::Int], description: "Linked proposal IDs of the result", required: false
      argument :proposal_ids, [GraphQL::Types::Int], description: "Linked project IDs of the result", required: false
      argument :start_date, GraphQL::Types::String, description: "Start date of this result(in 'dd-mm-yyyy' format)", required: false
      argument :taxonomies, [GraphQL::Types::Int], description: "Taxonomies of the result", required: false
      argument :title, GraphQL::Types::JSON, description: "Title of this result", required: false
      argument :weight, GraphQL::Types::Int, description: "Order of this result", required: false
    end
  end
end
