# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaType < GraphQL::Schema::Object
      graphql_name "MeetingAgenda"
      description "A meeting agenda"
      implements Decidim::Core::TimestampsInterface

      field :id, !types.ID, "The ID for the agenda"
      field :title, Decidim::Core::TranslatedFieldType, "The title for the agenda"
      field :items, !types[AgendaItemType], "Items and sub-items of the agenda", property: :agenda_items
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible
    end
  end
end
