# frozen-string_literal: true

module Decidim
  module Meetings
    # This module is used to be included in events triggered by comments.
    #
    module MeetingEvent
      extend ActiveSupport::Concern
      include Decidim::Events::MachineTranslatedEvent

      included do
        def resource_text
          translated_attribute(resource.description)
        end

        def translatable_resource
          resource
        end

        def translatable_text
          resource.description
        end

        def safe_resource_text
          locale = resource.respond_to?(:content_original_language) ? resource.content_original_language : I18n.locale
          I18n.with_locale(locale) { translated_attribute(resource.description).to_s.html_safe }
        end

        def safe_resource_translated_text
          return safe_resource_text unless perform_translation?

          I18n.with_locale(I18n.locale) { translated_attribute(resource.description, nil, true).to_s.html_safe }
        end
      end
    end
  end
end
