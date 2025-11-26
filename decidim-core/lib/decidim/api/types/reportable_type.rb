# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a content report
    class ReportableType < Decidim::Api::Types::BaseObject
      description "A report object"

      implements Decidim::Core::TimestampsInterface

      field :details, GraphQL::Types::String, "The details of this report", null: false
      field :id, GraphQL::Types::ID, "The ID of this reportable", null: false
      field :locale, GraphQL::Types::String, "The locale of the reportable", null: false
      field :reason, GraphQL::Types::String, "The reason of this report", null: false
      field :user, UserType, "The author of this report", null: true
    end
  end
end
