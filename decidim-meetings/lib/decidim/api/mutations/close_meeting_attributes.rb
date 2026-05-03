# frozen_string_literal: true

module Decidim
  module Meetings
    class CloseMeetingAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "CloseMeetingAttributes"
      description "Attributes for closing a meeting"

      argument :attendees_count, GraphQL::Types::Int, description: "Number of attendees", required: true
      argument :closed_at, Decidim::Core::DateTimeType,
               description: "Optional custom date and time when the meeting was closed. If omitted, the meeting will be closed at the current time (as in the UI).
This field is only available via the API to support integrations (for example, importing or synchronizing meetings with externally managed closure times).", required: false
      argument :closing_report, GraphQL::Types::String, description: "The closing report for the meeting", required: true
      argument :proposal_ids, [GraphQL::Types::ID], description: "IDs of proposals to link to the meeting", required: false
    end
  end
end
