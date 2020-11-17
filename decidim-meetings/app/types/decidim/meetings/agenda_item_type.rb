# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaItemType < GraphQL::Schema::Object
      graphql_name "MeetingAgendaItem"
      description "A meeting agenda item"
      implements Decidim::Core::TimestampsInterface

      field :id, !types.ID, "The ID for this agenda item"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this agenda item"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this agenda item"
      field :items, !types[AgendaItemType], "Sub-items (children) of this agenda item", property: :agenda_item_children
      field :parent, AgendaItemType, "Parent agenda item, if available"
      field :agenda, AgendaType, "Belonging agenda"
      field :duration, !types.Int, "Duration in number of minutes for this item in this agenda"
      field :position, !types.Int, "Order position for this agenda item"
    end
  end
end
