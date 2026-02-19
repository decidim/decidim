# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsMutationType < Decidim::Core::ComponentType
      graphql_name "MeetingsMutation"
      description "A meetings component with mutations."

      field :create_meeting, mutation: Decidim::Meetings::CreateMeetingType, description: "Creates a new meeting"
      field :meeting, type: Decidim::Meetings::MeetingMutationType, description: "Mutates a meeting", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the meeting", required: true
      end

      def meeting(id:)
        collection.find(id)
      end

      private

      def collection
        Meeting.where(component: object).not_hidden.published
      end
    end
  end
end
