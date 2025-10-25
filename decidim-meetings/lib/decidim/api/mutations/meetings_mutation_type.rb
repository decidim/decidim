# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsMutationType < Decidim::Core::ComponentType
      graphql_name "MeetingsMutation"
      description "A meetings component with its available mutations"

      field :create_meeting, mutation: Decidim::Meetings::CreateMeetingType, description: "Creates a new meeting"
    end
  end
end
