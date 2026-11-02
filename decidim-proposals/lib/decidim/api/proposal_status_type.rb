# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalStatusType < Decidim::Api::Types::BaseObject
      description "A proposal status"

      field :announcement_title, Decidim::Core::TranslatedFieldType, "The announcement for this proposal status", null: true
      field :bg_color, GraphQL::Types::String, description: "The background color of proposal status label", null: true
      field :id, GraphQL::Types::ID, "The id of the proposal status", null: false
      field :proposals_count, GraphQL::Types::Int, "The number of proposals having this status", null: true
      field :text_color, GraphQL::Types::String, description: "The text color of this proposal status label", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this proposal status", null: true
    end
  end
end
