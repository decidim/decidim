# frozen_string_literal: true

module Decidim
  # A Helper that reimplements the SocialShareButton gem helpers, so that we do not depend on it anymore.
  module SocialShareButtonHelper
    def social_share_button_tag(title, args)
      return unless enabled_services.length.positive?

      content_tag :div, class: "share-modal__list", data: { social_share: "" } do
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
        rel: "nofollow noopener noreferrer",
        target: "_blank",
        data: {
          "site" => service.name.downcase,
          "external-link" => false,
          "external-domain-link" => false
        },
        title: t("decidim.shared.share_modal.share_to", service: service.name)
      ) do
        render_social_share_icon(service) + content_tag(:span, service.name)
      end
    end

    def render_social_share_icon(service, options = {})
      if service.icon.include? ".svg"
        image_tag service.icon_path, options.merge(alt: t("decidim.shared.share_modal.share_to", service: service.name))
      else
        icon(service.icon, options.merge(ignore_missing: true, style: "color: #{service.icon_color};"))
      end
    end

    private

    def enabled_services
      Decidim.config.social_share_services.map { |service_name| Decidim.social_share_services_registry.find(service_name) }
    end
  end
end
