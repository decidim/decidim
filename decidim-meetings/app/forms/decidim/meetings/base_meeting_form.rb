# frozen_string_literal: true

module Decidim
  module Meetings
    class BaseMeetingForm < Decidim::Form
      include Decidim::HasTaxonomyFormAttributes

      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :online_meeting_url, String
      attribute :type_of_meeting, String
      attribute :start_time, Decidim::Attributes::TimeWithZone
      attribute :end_time, Decidim::Attributes::TimeWithZone

      validates :current_component, presence: true

      validates :start_time, presence: true, date: { before: :end_time }
      validates :end_time, presence: true, date: { after: :start_time }

      def participatory_space_manifest
        @participatory_space_manifest ||= current_component.participatory_space.manifest.name
      end

      def type_of_meeting_select
        Decidim::Meetings::Meeting::TYPE_OF_MEETING.keys.map do |type|
          [
            I18n.t("type_of_meeting.#{type}", scope: "decidim.meetings"),
            type
          ]
        end
      end

      def geocoding_enabled?
        Decidim::Map.available?(:geocoding)
      end

      def geocoded?
        latitude.present? && longitude.present?
      end

      def has_address?
        geocoding_enabled? && address.present?
      end

      def needs_address?
        in_person_meeting? || hybrid_meeting?
      end

      def online_meeting?
        type_of_meeting == "online"
      end

      def in_person_meeting?
        type_of_meeting == "in_person"
      end

      def hybrid_meeting?
        type_of_meeting == "hybrid"
      end
    end
  end
end
