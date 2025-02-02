# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsType < Decidim::Core::ComponentType
      graphql_name "Meetings"
      description "A meetings component of a participatory space."

      field :meetings, Decidim::Meetings::MeetingType.connection_type, "A collection of Meetings", null: true, connection: true

      field :meeting, Decidim::Meetings::MeetingType, "A single Meeting object", null: true do
        argument :id, GraphQL::Types::ID, required: true
      end

      def meetings
        Meeting.published.visible.where(component: object).includes(:component)
      end

      def meeting(**args)
        Meeting.published.visible.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
