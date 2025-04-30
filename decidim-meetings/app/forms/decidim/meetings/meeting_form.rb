# frozen_string_literal: true

module Decidim
  module Meetings
    # This class holds a Form to create/update meetings for Participants
    class MeetingForm < ::Decidim::Meetings::BaseMeetingForm
      attribute :title, String
      attribute :description, String
      attribute :location, String
      attribute :location_hints, String

      attribute :registration_type, String
      attribute :registrations_enabled, Boolean, default: false
      attribute :registration_url, String
      attribute :available_slots, Integer, default: 0
      attribute :registration_terms, String
      attribute :iframe_embed_type, String, default: "none"
      attribute :iframe_access_level, String

      validates :address, presence: true, if: ->(form) { form.needs_address? }
      validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? && form.needs_address? }
      validates :iframe_embed_type, inclusion: { in: Decidim::Meetings::Meeting.participants_iframe_embed_types }
      validates :title, presence: true, etiquette: true
      validates :description, presence: true, etiquette: true
      validates :type_of_meeting, presence: true
      validates :location, presence: true, if: ->(form) { form.in_person_meeting? || form.hybrid_meeting? }
      validates :online_meeting_url, presence: true, url: true, if: ->(form) { form.online_meeting? || form.hybrid_meeting? }
      validates :registration_type, presence: true
      validates :available_slots, numericality: { greater_than_or_equal_to: 0 }, presence: true, if: ->(form) { form.on_this_platform? }
      validates :registration_terms, presence: true, if: ->(form) { form.on_this_platform? }
      validates :registration_url, presence: true, url: true, if: ->(form) { form.on_different_platform? }
      validates :clean_type_of_meeting, presence: true
      validates(
        :iframe_access_level,
        inclusion: { in: Decidim::Meetings::Meeting.iframe_access_levels },
        if: ->(form) { %w(embed_in_meeting_page open_in_new_tab).include?(form.iframe_embed_type) }
      )
      validate :embeddable_meeting_url

      def map_model(model)
        presenter = MeetingEditionPresenter.new(model)
        self.title = presenter.title(all_locales: false)
        self.description = presenter.editor_description(all_locales: false)
        self.location = presenter.location(all_locales: false)
        self.location_hints = presenter.location_hints(all_locales: false)
        self.registration_terms = presenter.registration_terms(all_locales: false)
        self.type_of_meeting = model.type_of_meeting
      end

      alias component current_component

      def clean_type_of_meeting
        type_of_meeting.presence
      end

      def type_of_meeting_select
        Decidim::Meetings::Meeting::TYPE_OF_MEETING.keys.map do |type|
          [
            I18n.t("type_of_meeting.#{type}", scope: "decidim.meetings"),
            type
          ]
        end
      end

      def iframe_access_level_select
        Decidim::Meetings::Meeting.iframe_access_levels.map do |level, _value|
          [
            I18n.t("iframe_access_level.#{level}", scope: "decidim.meetings"),
            level
          ]
        end
      end

      def iframe_embed_type_select
        Decidim::Meetings::Meeting.participants_iframe_embed_types.map do |type, _value|
          [
            I18n.t("iframe_embed_type.#{type}", scope: "decidim.meetings"),
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

      def registration_type_select
        Decidim::Meetings::Meeting::REGISTRATION_TYPES.keys.map do |type|
          [
            I18n.t("registration_type.#{type}", scope: "decidim.meetings"),
            type
          ]
        end
      end

      def registrations_enabled
        on_this_platform?
      end

      def embeddable_meeting_url
        if online_meeting_url.present? && %w(embed_in_meeting_page open_in_live_event_page).include?(iframe_embed_type)
          embedder_service = Decidim::Meetings::MeetingIframeEmbedder.new(online_meeting_url)
          errors.add(:iframe_embed_type, :not_embeddable) unless embedder_service.embeddable?
        end
      end
    end
  end
end
