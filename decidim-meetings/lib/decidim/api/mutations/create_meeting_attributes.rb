# frozen_string_literal: true

module Decidim
  module Meetings
    class CreateMeetingAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "MeetingAttributes"
      description "Attributes for creating a meeting"

      argument :address, GraphQL::Types::String, description: "The address of the meeting", required: false
      argument :available_slots, GraphQL::Types::Int, description: "Number of available slots for registration", required: false
      argument :description, GraphQL::Types::String, description: "The description of the meeting", required: true
      argument :end_time, Decidim::Core::DateTimeType, description: "The end time of the meeting", required: true
      argument :iframe_access_level, GraphQL::Types::String, description: "Who can access the iframe: 'all', 'registered', 'signed_in'", required: false
      argument :iframe_embed_type, GraphQL::Types::String, description: "How to embed the iframe: 'none', 'embed_in_meeting_page', 'open_in_live_event_page', 'open_in_new_tab'",
                                                           required: false
      argument :latitude, GraphQL::Types::Float, description: "The latitude coordinate", required: false
      argument :location, GraphQL::Types::String, description: "The physical location of the meeting", required: false
      argument :location_hints, GraphQL::Types::String, description: "Hints about the location", required: false
      argument :longitude, GraphQL::Types::Float, description: "The longitude coordinate", required: false
      argument :online_meeting_url, GraphQL::Types::String, description: "URL for online meeting", required: false
      argument :registration_terms, GraphQL::Types::String, description: "Terms and conditions for registration", required: false
      argument :registration_type, GraphQL::Types::String, description: "Type of registration: 'on_this_platform', 'on_different_platform', or 'registration_disabled'",
                                                           required: true
      argument :registration_url, GraphQL::Types::String, description: "External registration URL", required: false
      argument :start_time, Decidim::Core::DateTimeType, description: "The start time of the meeting", required: true
      argument :taxonomy_ids, [GraphQL::Types::ID], description: "The IDs of taxonomies (categories/tags) to associate with the meeting", required: false
      argument :title, GraphQL::Types::String, description: "The title of the meeting", required: true
      argument :type_of_meeting, GraphQL::Types::String, description: "The type of meeting: 'online', 'in_person', or 'hybrid'", required: true
    end
  end
end
