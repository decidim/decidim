# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      graphql_name "MeetingAgenda"
      description "A meeting agenda"

      field :id, GraphQL::Types::ID, "The ID for the agenda", null: false
      field :items, [Decidim::Meetings::AgendaItemType, { null: true }], "Items and sub-items of the agenda", method: :agenda_items, null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for the agenda", null: true
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible
    end
  end
end
