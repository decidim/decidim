# frozen_string_literal: true

module Decidim
  module Core
    # This type represents an user report
    class ReportableUserType < Decidim::Api::Types::BaseObject
      description "An user report"

      implements Decidim::Core::TimestampsInterface

      field :details, GraphQL::Types::String, "The details of this report", null: false
      field :id, GraphQL::Types::ID, "The ID of this report", null: false
      field :reason, GraphQL::Types::String, "The reason of this report", null: false
      field :user, UserType, "The author of this report", null: true
    end
  end
end
