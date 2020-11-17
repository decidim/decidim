# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaItemType < GraphQL::Schema::Object
      graphql_name "MeetingAgendaItem"
      description "A meeting agenda item"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description:  "The ID for this agenda item"
      field :title, Decidim::Core::TranslatedFieldType, null: true , description: "The title for this agenda item"
      field :description, Decidim::Core::TranslatedFieldType, null: true , description: "The description for this agenda item"
      field :items, [AgendaItemType], null: false, description:  "Sub-items (children) of this agenda item" do
        def resolve(object:, _args:, context:)
          object.agenda_item_children
        end
      end
      field :parent, AgendaItemType,null: true , description:  "Parent agenda item, if available"
      field :agenda, AgendaType, null: true , description: "Belonging agenda"
      field :duration, Int, null: false, description: "Duration in number of minutes for this item in this agenda"
      field :position, Int, null: false, description:  "Order position for this agenda item"
    end
  end
end
