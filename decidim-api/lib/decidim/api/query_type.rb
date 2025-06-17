# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root query type of the whole API.
    class QueryType < Decidim::Api::Types::BaseObject
      description "The root query of this schema"

      field :participant_details, type: Decidim::Api::ParticipantDetailsType, null: true do
        description "Participant details visible to admin users only"
        argument :id, GraphQL::Types::ID, "The ID of the participant", required: true
        argument :nickname, GraphQL::Types::String, "The @nickname of the participant", required: false
      end

      field :component, Decidim::Core::ComponentInterface, null: true do
        description "A compnent"
        argument :id, GraphQL::Types::ID, required: true, description: "ID of the component"
      end
    end
  end
end
