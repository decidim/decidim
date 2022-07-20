# frozen_string_literal: true

module Decidim
  # A Helper that reimplements the SocialShareButton gem helpers, so that we don't depend on it anymore.
  module SocialShareButtonHelper
    def social_share_button_tag(title, args)
      return unless enabled_services.length.positive?

      content_tag :div, class: "social-share-button" do
        render_social_share_buttons(enabled_services, title, args)
      end
    end

    def render_social_share_buttons(services, title, args)
      services.map do |service|
        render_social_share_button(service, title, args)
      end.join.html_safe
    end

    def render_social_share_button(service, title, args)
      uri = service.formatted_share_uri(title, args)
      return unless uri

      link_to(
        uri,
        rel: "nofollow",
        data: { site: service.name.downcase },
        class: "ssb-icon ssb-#{service.name.downcase}",
        title: t("decidim.shared.share_modal.share_to", service: service.name)
      ) do
        image_tag service.icon_path
      end
    end

    private

    def enabled_services
      Decidim.config.social_share_services.map { |service_name| Decidim.social_share_service_registry.find(service_name) }
    end
  end
end
