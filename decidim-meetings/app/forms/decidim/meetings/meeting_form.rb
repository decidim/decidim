# frozen_string_literal: true

module Decidim
  module Meetings
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class MeetingForm < Decidim::Form
      attribute :title, String
      attribute :description, String
      attribute :location, String
      attribute :location_hints, String

      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :start_time, Decidim::Attributes::TimeWithZone
      attribute :end_time, Decidim::Attributes::TimeWithZone
      attribute :decidim_scope_id, Integer
      attribute :decidim_category_id, Integer
      attribute :user_group_id, Integer
      attribute :online_meeting_url, String
      attribute :type_of_meeting, String
      attribute :registration_type, String
      attribute :registration_url, String
      attribute :available_slots, Integer, default: 0
      attribute :registration_terms, String

      TYPE_OF_MEETING = %w(in_person online).freeze
      REGISTRATION_TYPE = %w(registration_disabled on_this_platform on_different_platform).freeze

      validates :title, presence: true
      validates :description, presence: true
      validates :type_of_meeting, presence: true, if: ->(form) { form.online_meetings_allowed? }
      validates :location, presence: true, if: ->(form) { form.in_person_meeting? }
      validates :address, presence: true, if: ->(form) { form.needs_address? }
      validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? && form.needs_address? }
      validates :online_meeting_url, presence: true, url: true, if: ->(form) { form.online_meeting? }
      validates :registration_type, presence: true
      validates :available_slots, numericality: { greater_than_or_equal_to: 0 }, presence: true, if: ->(form) { form.on_this_platform? }
      validates :registration_terms, presence: true, if: ->(form) { form.on_this_platform? }
      validates :registration_url, presence: true, url: true, if: ->(form) { form.on_different_platform? }
      validates :start_time, presence: true, date: { before: :end_time }
      validates :end_time, presence: true, date: { after: :start_time }

      validates :current_component, presence: true
      validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
      validates :decidim_scope_id, scope_belongs_to_component: true, if: ->(form) { form.decidim_scope_id.present? }
      validates :clean_type_of_meeting, presence: true

      delegate :categories, to: :current_component

      def map_model(model)
        self.decidim_category_id = model.categorization.decidim_category_id if model.categorization
        presenter = MeetingPresenter.new(model)
        self.title = presenter.title(all_locales: false)
        self.description = presenter.description(all_locales: false)
        self.type_of_meeting = if model.online_meeting?
                                 "online"
                               else
                                 "in_person"
                               end
      end

      alias component current_component

      # Finds the Scope from the given decidim_scope_id, uses the compoenent scope if missing.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= @decidim_scope_id ? current_component.scopes.find_by(id: @decidim_scope_id) : current_component.scope
      end

      # Scope identifier
      #
      # Returns the scope identifier related to the meeting
      def decidim_scope_id
        @decidim_scope_id || scope&.id
      end

      def category
        return unless current_component

        @category ||= categories.find_by(id: decidim_category_id)
      end

      def geocoding_enabled?
        Decidim::Map.available?(:geocoding)
      end

      def has_address?
        geocoding_enabled? && address.present?
      end

      def needs_address?
        in_person_meeting?
      end

      def geocoded?
        latitude.present? && longitude.present?
      end

      def online_meeting?
        online_meetings_allowed? && type_of_meeting == "online"
      end

      def in_person_meeting?
        if online_meetings_allowed?
          type_of_meeting == "in_person"
        else
          type_of_meeting == "in_person" || type_of_meeting.presence.nil?
        end
      end

      def online_meetings_allowed?
        current_component.settings.allow_online_meetings?
      end

      def clean_type_of_meeting
        return "in_person" unless online_meetings_allowed?

        type_of_meeting.presence
      end

      def type_of_meeting_select
        TYPE_OF_MEETING.map do |type|
          [
            I18n.t("type_of_meeting.#{type}", scope: "decidim.meetings"),
            type
          ]
        end
      end

      def on_this_platform?
        registration_type == "on_this_platform"
      end

      def on_different_platform?
        registration_type == "on_different_platform"
      end

      def external_registrations_allowed?
        current_component.settings.allow_external_registrations?
      end

      def registration_type_select
        REGISTRATION_TYPE.map do |type|
          next if !external_registrations_allowed? && type == "on_different_platform"

          [
            I18n.t("registration_type.#{type}", scope: "decidim.meetings"),
            type
          ]
        end.compact
      end
    end
  end
end
