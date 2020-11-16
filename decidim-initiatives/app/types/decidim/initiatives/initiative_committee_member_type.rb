# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents a initiative committee member.
    InitiativeCommitteeMemberType = GraphQL::ObjectType.define do
      name "InitiativeCommitteeMemberType"
      description "A initiative committee member"
      implements Decidim::Core::TimestampsInterface

      field :id, !types.ID, "Internal ID for this member of the committee"
      field :user, Decidim::Core::UserType, "The decidim user for this initiative committee member"

      field :state, types.Int, "Type of the committee member"
    end
  end
end
