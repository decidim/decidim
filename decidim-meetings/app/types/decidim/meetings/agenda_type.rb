# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaType < GraphQL::Schema::Object
      graphql_name "MeetingAgenda"
      description "A meeting agenda"
      implements Decidim::Core::TimestampsInterface

      field :id, ID,null: false, description:  "The ID for the agenda"
      field :title, Decidim::Core::TranslatedFieldType, null: true , description: "The title for the agenda"
      field :items, [AgendaItemType],null: false, description:  "Items and sub-items of the agenda" do
        def resolve(object:, _args:, context:)
          object.agenda_items
        end
      end
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible
    end
  end
end
