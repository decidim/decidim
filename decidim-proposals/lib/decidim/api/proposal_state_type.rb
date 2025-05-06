# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalStateType < Decidim::Api::Types::BaseObject
      description "A proposal state"

      field :announcement_title, Decidim::Core::TranslatedFieldType, "The announcement for this proposal state", null: true
      field :bg_color, GraphQL::Types::String, description: "The background color of proposal state label", null: true
      field :id, GraphQL::Types::ID, "The id of the Proposal state", null: false
      field :proposals_count, GraphQL::Types::Int, "The announcement for this proposal state", null: true
      field :text_color, GraphQL::Types::String, description: "The text color of proposal state label", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this proposal state", null: true
    end
  end
end
