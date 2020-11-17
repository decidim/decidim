# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingType < GraphQL::Schema::Object
      graphql_name "Meeting"
      description "A meeting"

      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Meetings::ServicesInterface
      implements Decidim::Meetings::LinkedResourcesInterface
      implements Decidim::Forms::QuestionnaireEntityInterface

      field :id, ID, null: false, description:  "ID of this meeting"
      field :reference, String, null: false, description:  "Reference for this meeting"
      field :title, Decidim::Core::TranslatedFieldType, null: false, description:  "The title of this meeting."
      field :description, Decidim::Core::TranslatedFieldType, null: true , description:  "The description of this meeting."
      field :startTime, Decidim::Core::DateTimeType, null: false, description:  "The time this meeting starts" do
        def resolve(object:, _args:, context:)
          object.start_time
        end
      end
      field :endTime, Decidim::Core::DateTimeType, null: false, description:  "The time this meeting ends" do
        def resolve(object:, _args:, context:)
          object.end_time
        end
      end
      field :author, Decidim::Core::AuthorInterface, null: true , description: "If specified, the author of this meeting"
      field :agenda, AgendaType,null: true , description:  "Agenda for this meeting, if available" do
        def resolve(meeting, _args, _ctx)
          meeting.agenda if meeting.agenda&.visible?
        end
      end

      field :closed, Boolean, null: false, description:  "Whether this meeting is closed or not." do
        def resolve(object:, _args:, context:)
          object.closed?
        end
      end
      field :closingReport, Decidim::Core::TranslatedFieldType, null: true , description: "The closing report of this meeting." do
        def resolve(object:, _args:, context:)
          object.closing_report
        end
      end
      field :attendingOrganizations, String, null: true , description: "list of attending organizations" do
        def resolve(object:, _args:, context:)
          object.attending_organizations
        end
      end
      field :attendeeCount, Int, null: true , description: "Amount of attendees to this meeting" do
        def resolve(object:, _args:, context:)
          object.attendees_count
        end
      end
      field :contributionCount, Int, null: true , description: "Amount of contributions to this meeting" do
        def resolve(object:, _args:, context:)
          object.contributions_count
        end
      end
      field :minutes, MinutesType,null: true , description:  "Minutes for this meeting, if available" do
        def resolve(meeting:, _args:, _ctx:)
          meeting.minutes if meeting.minutes&.visible?
        end
      end
      field :privateMeeting, Boolean, null: false, description: "Whether the meeting is private or not (it can only be true if transparent)" do
        def resolve(object:, _args:, context:)
          object.private_meeting
        end
      end
      field :transparent, Boolean, null: false, description: "For private meetings, information is public if transparent"
      field :registrationsEnabled, Boolean, null: false, description: "Whether the registrations are enabled or not" do
        def resolve(object:, _args:, context:)
          object.registrations_enabled
        end
        end
      field :registrationTerms, Decidim::Core::TranslatedFieldType, null: true , description: "The registration terms" do
        def resolve(object:, _args:, context:)
          object.registration_terms
        end
      end
      field :remainingSlots, Int, null: true , description: "Amount of slots available for this meeting" do
        def resolve(object:, _args:, context:)
          object.remaining_slots
        end
      end
      field :registrationFormEnabled, Boolean, null: false, description:  "Whether the registrations have a form or not" do
        def resolve(object:, _args:, context:)
          object.registration_form_enabled
        end
      end
      field :registrationForm, Decidim::Forms::QuestionnaireType, null: true , description: "If registration requires to fill a form, this is the questionnaire" do
        def resolve(meeting, _args, _ctx)
          meeting.questionnaire if meeting.registration_form_enabled?
        end
      end
      field :location, Decidim::Core::TranslatedFieldType, null: true , description: "The location of this meeting (free format)"
      field :locationHints, Decidim::Core::TranslatedFieldType, null: true , description: "The location of this meeting (free format)" do
        def resolve(object:, _args:, context:)
          object.location_hints
        end
      end
      field :address, String, null: true , description: "The physical address of this meeting (used for geolocation)"
      field :coordinates, Decidim::Core::CoordinatesType, null: true , description:  "Physical coordinates for this meeting" do
        def resolve(meeting, _args, _ctx)
          [meeting.latitude, meeting.longitude]
        end
      end
      field :typeOfMeeting, String, null: false, description: "The type of the meeting (online or in-person)"
      field :onlineMeetingUrl, String, null: false, description: "The URL of the meeting (when the type is online)"
    end
  end
end
