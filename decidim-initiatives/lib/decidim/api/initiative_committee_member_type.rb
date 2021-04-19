# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents a initiative committee member.
    class InitiativeCommitteeMemberType < Decidim::Api::Types::BaseObject
      graphql_name "InitiativeCommitteeMemberType"
      description "A initiative committee member"

      field :id, GraphQL::Types::ID, "Internal ID for this member of the committee", null: false
      field :user, Decidim::Core::UserType, "The decidim user for this initiative committee member", null: true

      field :state, GraphQL::Types::String, "Type of the committee member", null: true
      field :created_at, Decidim::Core::DateTimeType, "The date this initiative committee member was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The date this initiative committee member was updated", null: true
    end
  end
end
