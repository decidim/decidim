# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingType < Decidim::Api::Types::BaseObject
      description "A meeting"

      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::TaxonomizableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Meetings::ServicesInterface
      implements Decidim::Meetings::LinkedResourcesInterface if Decidim::Meetings.enable_proposal_linking
      implements Decidim::Forms::QuestionnaireEntityInterface

      field :address, GraphQL::Types::String, "The physical address of this meeting (used for geolocation)", null: true
      field :agenda, Decidim::Meetings::AgendaType, "Agenda for this meeting, if available", null: true
      field :attendee_count, GraphQL::Types::Int, "Amount of attendees to this meeting", method: :attendees_count, null: true
      field :attending_organizations, GraphQL::Types::String, "list of attending organizations", null: true
      field :audio_url, GraphQL::Types::String, "URL for the audio of the session, if any", null: true
      field :closed, GraphQL::Types::Boolean, "Whether this meeting is closed or not.", method: :closed?, null: false
      field :closing_report, Decidim::Core::TranslatedFieldType, "The closing report of this meeting.", null: true
      field :contribution_count, GraphQL::Types::Int, "Amount of contributions to this meeting", method: :contributions_count, null: true
      field :coordinates, Decidim::Core::CoordinatesType, "Physical coordinates for this meeting", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this meeting.", null: true
      field :end_time, Decidim::Core::DateTimeType, "The time this meeting ends", null: false
      field :id, GraphQL::Types::ID, "ID of this meeting", null: false
      field :iframe_embed_type, GraphQL::Types::String, "The type of displaying of the online meeting URL", null: true
      field :is_withdrawn, GraphQL::Types::Boolean, "Whether this meeting is withdrawn or not.", method: :withdrawn?, null: false
      field :location, Decidim::Core::TranslatedFieldType, "The location of this meeting (free format)", null: true
      field :location_hints, Decidim::Core::TranslatedFieldType, "The location of this meeting (free format)", null: true
      field :online_meeting_url, GraphQL::Types::String, "The URL of the meeting (when the type is online)", null: false
      field :private_meeting, GraphQL::Types::Boolean, "Whether the meeting is private or not (it can only be true if transparent)", null: false
      field :reference, GraphQL::Types::String, "Reference for this meeting", null: false
      field :registration_form, Decidim::Forms::QuestionnaireType, description: "If registration requires to fill a form, this is the questionnaire", null: true
      field :registration_form_enabled, GraphQL::Types::Boolean, "Whether the registrations have a form or not", null: false
      field :registration_terms, Decidim::Core::TranslatedFieldType, "The registration terms", null: true
      field :registrations_enabled, GraphQL::Types::Boolean, "Whether the registrations are enabled or not", null: false
      field :remaining_slots, GraphQL::Types::Int, "Amount of slots available for this meeting", null: true
      field :start_time, Decidim::Core::DateTimeType, "The time this meeting starts", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this meeting.", null: false
      field :transparent, GraphQL::Types::Boolean, "For private meetings, information is public if transparent", null: false
      field :type_of_meeting, GraphQL::Types::String, "The type of the meeting (online or in-person)", null: false
      field :video_url, GraphQL::Types::String, "URL for the video of the session, if any", null: true
      field :withdrawn, GraphQL::Types::Boolean, "Whether this meeting has been withdrawn or not", method: :withdrawn?, null: true
      field :withdrawn_at, Decidim::Core::DateTimeType, description: "The date and time this meeting was withdrawn", null: true

      def registration_form
        object.questionnaire if object.registration_form_enabled?
      end

      def agenda
        object.agenda if object.agenda&.visible?
      end

      def closing_report
        object.closing_report if object.closing_visible?
      end

      def video_url
        object.video_url if object.closing_visible?
      end

      def audio_url
        object.audio_url if object.closing_visible?
      end

      def coordinates
        [object.latitude, object.longitude]
      end

      def self.authorized?(object, context)
        context[:meeting] = object

        chain = [
          allowed_to?(:read, :meeting, object, context),
          object.published?,
          object.current_user_can_visit_meeting?(context[:current_user])
        ].all?

        super && chain
      end
    end
  end
end
