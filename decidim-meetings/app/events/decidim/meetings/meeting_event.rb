# frozen-string_literal: true

module Decidim
  module Meetings
    # This module is used to be included in events triggered by comments.
    #
    module MeetingEvent
      extend ActiveSupport::Concern

      included do
        def resource_text
          translated_attribute(resource.description)
        end

        def perform_translation?
          organization.enable_machine_translations
        end

        def content_in_same_language?
          return false unless perform_translation?
          return false unless resource.respond_to?(:content_original_language)

          resource.content_original_language == I18n.locale.to_s
        end

        def translation_missing?
          return false unless perform_translation?

          resource.description.dig("machine_translations", I18n.locale.to_s).blank?
        end

        def safe_resource_text
          locale = resource.respond_to?(:content_original_language) ? resource.content_original_language : I18n.locale
          I18n.with_locale(locale) { translated_attribute(resource.description).to_s.html_safe }
        end

        def safe_resource_translated_text
          return safe_resource_text unless perform_translation?

          I18n.with_locale(I18n.locale) { translated_attribute(resource.description).to_s.html_safe }
        end
      end
    end
  end
end
