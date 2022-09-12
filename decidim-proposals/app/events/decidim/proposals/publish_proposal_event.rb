# frozen-string_literal: true

module Decidim
  module Proposals
    class PublishProposalEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::CoauthorEvent
      include Decidim::Core::Engine.routes.url_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::Events::MachineTranslatedEvent

      def resource_text
        resource.body
      end

      def i18n_options
        return super if author.blank?

        author_path = link_to("@#{author.nickname}", profile_path(author.nickname))
        author_string = "#{author.name} #{author_path}"
        super.merge({ author: author_string })
      end

      def translatable_resource
        resource
      end

      def translatable_text
        resource.body
      end

      def safe_resource_text
        locale = resource.respond_to?(:content_original_language) ? resource.content_original_language : I18n.locale
        I18n.with_locale(locale) { translated_attribute(resource_text).to_s.html_safe }
      end

      def safe_resource_translated_text
        I18n.with_locale(I18n.locale) { translated_attribute(resource_text, nil, true).to_s.html_safe }
      end

      def notification_title
        i18n_key = resource.official? ? "notification_title_official" : "notification_title"

        I18n.t(i18n_key, **i18n_options).html_safe
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
