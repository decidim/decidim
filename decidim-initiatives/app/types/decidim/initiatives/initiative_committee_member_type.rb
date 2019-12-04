# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents a conference.
    InitiativeCommitteeMemberType = GraphQL::ObjectType.define do
      name "InitiativeCommitteeMemberType"
      description "A initiative committee member"

      field :id, !types.ID, "Internal ID for this member of the committee"
      field :user, Decidim::Core::UserType, "The decidim user for this initiative committee member"

      field :state, types.Int, "Type of the committee member"
      field :createdAt, Decidim::Core::DateTimeType, "The date this initiative committee member was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The date this initiative committee member was updated", property: :updated_at
    end
  end
end
