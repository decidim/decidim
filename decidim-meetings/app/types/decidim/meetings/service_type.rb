# frozen_string_literal: true

module Decidim
  module Meetings
    ServiceType = GraphQL::ObjectType.define do
      name "MeetingService"
      description "A meeting service"

      field :title, Decidim::Core::TranslatedFieldType, "The title for the service"
      field :description, Decidim::Core::TranslatedFieldType, "The description for the service"
    end
  end
end
