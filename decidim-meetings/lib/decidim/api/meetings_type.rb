# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsType < Decidim::Core::ComponentType
      graphql_name "Meetings"
      description "A meetings component of a participatory space."

      field :meeting, Decidim::Meetings::MeetingType, "A single Meeting object", null: true do
        argument :id, GraphQL::Types::ID, "The id of the Meeting requested", required: true
      end
      field :meetings, Decidim::Meetings::MeetingType.connection_type, "A collection of Meetings", null: true, connection: true

      def meetings
        Meeting.published.visible.where(component: object).includes(:component)
      end

      def meeting(id:)
        Decidim::Core::ComponentFinderBase.new(model_class: Meeting.published.visible).call(object, { id: }, context)
      end
    end
  end
end
