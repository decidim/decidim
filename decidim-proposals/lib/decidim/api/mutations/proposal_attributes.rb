# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ProposalAttributes"
      description "Attributes for creating a proposal"

      argument :address, GraphQL::Types::String, description: "Physical address for the proposal", required: false
      argument :body, GraphQL::Types::String, description: "The body content of the proposal", required: true
      argument :latitude, GraphQL::Types::Float, description: "Latitude coordinate", required: false
      argument :longitude, GraphQL::Types::Float, description: "Longitude coordinate", required: false
      argument :taxonomies, [GraphQL::Types::ID], description: "Array of taxonomy IDs", required: false
      argument :title, GraphQL::Types::String, description: "The title of the proposal", required: true
    end
  end
end
