# frozen_string_literal: true

module Decidim
  module Meetings
    class UpdateMeetingAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "UpdateMeetingAttributes"
      description "Attributes to update a meeting"

      argument :title, GraphQL::Types::JSON, description: "The title of the meeting", required: false
      argument :description, GraphQL::Types::JSON, description: "The description of the meeting", required: false
      argument :location, GraphQL::Types::JSON, description: "The location of the meeting", required: false
      argument :location_hints, GraphQL::Types::JSON, description: "Location hints for the meeting", required: false
      argument :start_time, Decidim::Core::DateTimeType, description: "Start time of the meeting", required: false
      argument :end_time, Decidim::Core::DateTimeType, description: "End time of the meeting", required: false
      argument :address, GraphQL::Types::String, description: "Address of the meeting", required: false
      argument :latitude, GraphQL::Types::Float, description: "Latitude coordinate", required: false
      argument :longitude, GraphQL::Types::Float, description: "Longitude coordinate", required: false
      argument :registration_type, GraphQL::Types::String, description: "Type of registration (on_this_platform, on_different_platform, registration_disabled)", required: false
      argument :registration_url, GraphQL::Types::String, description: "URL for registration on different platform", required: false
      argument :available_slots, GraphQL::Types::Int, description: "Number of available slots for registration", required: false
      argument :registration_terms, GraphQL::Types::JSON, description: "Terms and conditions for registration", required: false
      argument :registrations_enabled, GraphQL::Types::Boolean, description: "Whether registrations are enabled", required: false
      argument :type_of_meeting, GraphQL::Types::String, description: "Type of meeting (in_person, online, hybrid)", required: false
      argument :online_meeting_url, GraphQL::Types::String, description: "URL for online meeting", required: false
      argument :iframe_embed_type, GraphQL::Types::String, description: "How to embed the online meeting (none, embed_in_meeting_page, open_in_live_event_page, open_in_new_tab)", required: false
      argument :iframe_access_level, GraphQL::Types::String, description: "Access level for iframe (all, registered, signed_in)", required: false
    end
  end
end
