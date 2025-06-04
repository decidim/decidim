# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaItemType < Decidim::Api::Types::BaseObject
      graphql_name "MeetingAgendaItem"
      description "A meeting agenda item"

      implements Decidim::Core::TimestampsInterface

      field :agenda, Decidim::Meetings::AgendaType, "Belonging agenda", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this agenda item", null: true
      field :duration, GraphQL::Types::Int, "Duration in number of minutes for this item in this agenda", null: false
      field :id, GraphQL::Types::ID, "The ID for this agenda item", null: false
      field :items, [Decidim::Meetings::AgendaItemType, { null: true }], "Sub-items (children) of this agenda item", method: :agenda_item_children, null: false
      field :parent, Decidim::Meetings::AgendaItemType, "Parent agenda item, if available", null: true
      field :position, GraphQL::Types::Int, "Order position for this agenda item", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this agenda item", null: true

      def self.authorized?(object, _context)
        object.agenda.visible?
      end
    end
  end
end
