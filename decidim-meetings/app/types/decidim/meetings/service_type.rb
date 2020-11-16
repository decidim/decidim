# frozen_string_literal: true

module Decidim
  module Meetings
    class ServiceType < GraphQL::Schema::Object
      graphql_name"MeetingService"
      description "A meeting service"

      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "The title for the service"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description for the service"
    end
  end
end
