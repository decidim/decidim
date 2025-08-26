# frozen_string_literal: true

module Decidim
  module Core
    class ReportableType < Decidim::Api::Types::BaseObject
      description "A report object"

      implements Decidim::Core::TimestampsInterface

      field :details, GraphQL::Types::String, "The details for this report", null: false
      field :id, GraphQL::Types::ID, "Internal ID for this reportable", null: false
      field :locale, GraphQL::Types::String, "The locale of the reportable", null: false
      field :reason, GraphQL::Types::String, "The reason for this report", null: false
      field :user, UserType, "The user that reported this", null: true
    end
  end
end
