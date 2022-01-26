# frozen-string_literal: true

module Decidim
  module Events
    module MachineTranslatedEvent
      extend ActiveSupport::Concern

      included do
        def perform_translation?
          organization.enable_machine_translations
        end

        def content_in_same_language?
          return false unless perform_translation?
          return false unless translatable_resource.respond_to?(:content_original_language)

          translatable_resource.content_original_language == I18n.locale.to_s
        end

        def translation_missing?
          return false unless perform_translation?

          translatable_text.dig("machine_translations", I18n.locale.to_s).blank?
        end

        def translatable_resource
          raise NotImplementedError
        end

        def translatable_text
          raise NotImplementedError
        end
      end
    end
  end
end
