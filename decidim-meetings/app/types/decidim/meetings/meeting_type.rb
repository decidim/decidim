# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingType = GraphQL::ObjectType.define do
      name "Meeting"
      description "A meeting"

      interfaces [
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::CategorizableInterface },
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Meetings::ServicesInterface }
      ]

      # TODO
      # linked_resources
      # registration form
      # Agenda (title, item-children(title,description,duration), ) IF VISIBLE

      field :id, !types.ID
      field :reference, !types.String
      field :title, !Decidim::Core::TranslatedFieldType, "The title of this meeting."
      field :description, Decidim::Core::TranslatedFieldType, "The description of this meeting."
      field :startTime, !Decidim::Core::DateTimeType, "The time this meeting starts", property: :start_time
      field :endTime, !Decidim::Core::DateTimeType, "The time this meeting ends", property: :end_time
      field :organizer, Decidim::Core::AuthorInterface, "If specified, the organizer of this meeting"

      field :closed, !types.Boolean, "Whether this meeting is closed or not.", property: :closed?
      field :closingReport, Decidim::Core::TranslatedFieldType, "The closing report of this meeting.", property: :closing_report
      field :attendingOrganizations, types.String, "list of attending organizations", property: :attending_organizations
      field :attendeeCount, types.Int, "Amount of attendees to this meeting", property: :attendees_count
      field :contributionCount, types.Int, "Amount of contributions to this meeting", property: :contributions_count
      field :minutes, MinutesType, "Minutes for this meeting, if available" do
        resolve ->(meeting, _args, _ctx) {
          meeting.minutes if meeting.minutes&.visible?
        }
      end
      field :registrationsEnabled, !types.Boolean, "Whether the registrations are enabled or not", property: :registrations_enabled
      field :registrationTerms, Decidim::Core::TranslatedFieldType, "The registration terms", property: :registration_terms
      field :remainingSlots, types.Int, "Amount of slots available for this meeting", property: :remaining_slots

      field :location, Decidim::Core::TranslatedFieldType, "The location of this meeting (free format)"
      field :locationHints, Decidim::Core::TranslatedFieldType, "The location of this meeting (free format)", property: :location_hints
      field :address, types.String, "The physical address of this meeting (used for geolocation)"
      field :coordinates, Decidim::Core::CoordinatesType, "Physical coordinates for this meeting" do
        resolve ->(meeting, _args, _ctx) {
          [meeting.latitude, meeting.longitude]
        }
      end
      field :registrationFormEnabled, !types.Boolean, "Whether the registrations have a form or not", property: :registration_form_enabled
      field :privateMeeting, !types.Boolean, "Whether the meeting is private or not (it can only be true if transparent)", property: :private_meeting
      field :transparent, !types.Boolean, "For private meetings, information is public if transparent", property: :transparent

      field :createdAt, Decidim::Core::DateTimeType do
        description "The date and time this meeting was created"
        property :created_at
      end

      field :updatedAt, Decidim::Core::DateTimeType do
        description "The date and time this meeting was updated"
        property :updated_at
      end
    end
  end
end
