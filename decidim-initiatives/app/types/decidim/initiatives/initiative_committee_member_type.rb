# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeCommitteeMemberType < GraphQL::Schema::Object
      graphql_name "InitiativeCommitteeMemberType"
      description "A initiative committee member"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "Internal ID for this member of the committee"
      field :user, Decidim::Core::UserType, null: true, description: "The decidim user for this initiative committee member"

      field :state, Int, null: true, description: "Type of the committee member"
    end
  end
end
