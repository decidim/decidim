# frozen_string_literal: true

module Decidim
  module Meetings
    AgendaType = GraphQL::ObjectType.define do
      name "MeetingAgenda"
      description "A meeting agenda"

      field :id, !types.ID, "The ID for the agenda"
      field :title, Decidim::Core::TranslatedFieldType, "The title for the agenda"
      field :items, !types[AgendaItemType], "Items and sub-items of the agenda", property: :agenda_items
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible

      field :createdAt, Decidim::Core::DateTimeType do
        description "The date and time this agenda was created"
        property :created_at
      end
      field :updatedAt, Decidim::Core::DateTimeType do
        description "The date and time this agenda was updated"
        property :updated_at
      end
    end
  end
end
