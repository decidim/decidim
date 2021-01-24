# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Meetings"
      description "A meetings component of a participatory space."

      field :meetings, Decidim::Meetings::MeetingType.connection_type, null: true, connection: true

      def meetings
        Meeting.visible.where(component: object).includes(:component)
      end

      field :meeting, Decidim::Meetings::MeetingType, null: true do
        argument :id, GraphQL::Types::ID, required: true
      end

      def meeting(**args)
        Meeting.visible.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
