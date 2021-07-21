# frozen-string_literal: true

module Decidim
  module Proposals
    class PublishProposalEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::CoauthorEvent

      def resource_text
        resource.body
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

        resource_text.dig("machine_translations", I18n.locale.to_s).blank?
      end

      def safe_resource_text
        locale = resource.respond_to?(:content_original_language) ? resource.content_original_language : I18n.locale
        I18n.with_locale(locale) { translated_attribute(resource_text).to_s.html_safe }
      end

      def safe_resource_translated_text
        I18n.with_locale(I18n.locale) { translated_attribute(resource_text).to_s.html_safe }
      end

      private

      def i18n_scope
        return super unless participatory_space_event?

        "decidim.events.proposals.proposal_published_for_space"
      end

      def participatory_space_event?
        extra[:participatory_space]
      end
    end
  end
end
