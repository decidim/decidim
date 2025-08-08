# frozen_string_literal: true

module Decidim
  module Meetings
    class UpdateMeetingEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent

      i18n_attributes :changed_fields

      def notification_title
        I18n.t(
          "notification_title",
          scope: i18n_scope,
          changed_fields: changed_fields,
          resource_title: translated_attribute(resource.title),
          resource_path: resource_path
        ).html_safe
      end

      private

      def changed_field_keys
        extra[:changed_fields] || []
      end

      def changed_fields
        keys = changed_field_keys
        return "" if keys.empty?

        keys.map { |key| I18n.t("field_names.#{key}", scope: i18n_scope) }.to_sentence
      end
    end
  end
end
