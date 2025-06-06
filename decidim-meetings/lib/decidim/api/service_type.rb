# frozen_string_literal: true

module Decidim
  module Meetings
    class ServiceType < Decidim::Api::Types::BaseObject
      graphql_name "MeetingService"
      description "A meeting service"

      implements Decidim::Core::TimestampsInterface

      field :description, Decidim::Core::TranslatedFieldType, "The description for the service", null: true
      field :id, GraphQL::Types::ID, "The ID of the service", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for the service", null: true
    end
  end
end
