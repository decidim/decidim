# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents an initiative committee member.
    class InitiativeCommitteeMemberType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      graphql_name "InitiativeCommitteeMemberType"
      description "An initiative committee member"

      field :id, GraphQL::Types::ID, "Internal ID for this member of the committee", null: false
      field :user, Decidim::Core::UserType, "The decidim user for this initiative committee member", null: true

      field :state, GraphQL::Types::String, "Type of the committee member", null: true
    end
  end
end
