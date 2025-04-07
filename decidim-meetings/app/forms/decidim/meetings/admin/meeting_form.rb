# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class MeetingForm < ::Decidim::Meetings::BaseMeetingForm
        include TranslatableAttributes

        attribute :services, Array[MeetingServiceForm]
        attribute :component_ids, Array[Integer]
        attribute :private_meeting, Boolean
        attribute :transparent, Boolean
        attribute :registration_type, String
        attribute :registrations_enabled, Boolean, default: false
        attribute :registration_url, String
        attribute :customize_registration_email, Boolean
        attribute :iframe_embed_type, String, default: "none"
        attribute :comments_enabled, Boolean, default: true
        attribute :comments_start_time, Decidim::Attributes::TimeWithZone
        attribute :comments_end_time, Decidim::Attributes::TimeWithZone
        attribute :iframe_access_level, String

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText
        translatable_attribute :location, String
        translatable_attribute :location_hints, String

        validates :iframe_embed_type, inclusion: { in: Decidim::Meetings::Meeting.iframe_embed_types }
        validates :title, :description, translatable_presence: true
        validates :title, :description, translated_etiquette: true
        validates :registration_type, presence: true
        validates :registration_url, presence: true, url: true, if: ->(form) { form.on_different_platform? }
        validates :type_of_meeting, presence: true
        validates :address, presence: true, if: ->(form) { form.needs_address? && form.location.values.any?(&:present?) && form.address.blank? }
        validates :location, translatable_presence: true, if: ->(form) { form.needs_address? && form.address.present? }
        validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? && form.needs_address? }
        validates :online_meeting_url, url: true, if: ->(form) { form.online_meeting? || form.hybrid_meeting? }
        validates :comments_start_time, date: { before: :comments_end_time, allow_blank: true, if: proc { |obj| obj.comments_end_time.present? } }
        validates :comments_end_time, date: { after: :comments_start_time, allow_blank: true, if: proc { |obj| obj.comments_start_time.present? } }
        validates :clean_type_of_meeting, presence: true
        validates(
          :iframe_access_level,
          inclusion: { in: Decidim::Meetings::Meeting.iframe_access_levels },
          if: ->(form) { %w(embed_in_meeting_page open_in_live_event_page open_in_new_tab).include?(form.iframe_embed_type) }
        )
        validate :embeddable_meeting_url

        def map_model(model)
          self.services = model.services.map do |service|
            MeetingServiceForm.from_model(service)
          end

          self.type_of_meeting = model.type_of_meeting

          presenter = MeetingEditionPresenter.new(model)
          self.title = presenter.title(all_locales: true)
          self.description = presenter.editor_description(all_locales: true)
        end

        def services_to_persist
          services.reject(&:deleted)
        end

        # linked components
        def components
          return [] if private_non_transparent_space?

          if private_meeting && !transparent
            []
          else
            Decidim::Component.where(id: component_ids)
          end
        end

        delegate :private_non_transparent_space?, to: :current_component

        def number_of_services
          services.size
        end

        alias component current_component

        def clean_type_of_meeting
          type_of_meeting.presence
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
          Decidim::Meetings::Meeting.iframe_embed_types.map do |type, _value|
            [
              I18n.t("iframe_embed_type.#{type}", scope: "decidim.meetings"),
              type
            ]
          end
        end

        # Support for copy meeting
        def questionnaire
          Decidim::Forms::Questionnaire.new
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
end
