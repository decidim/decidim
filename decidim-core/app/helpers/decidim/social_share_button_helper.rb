# frozen_string_literal: true

module Decidim
  # A Helper that reimplements the SocialShareButton gem helpers, so that we do not depend on it anymore.
  module SocialShareButtonHelper
    def social_share_button_tag(title, args)
      return unless enabled_services.length.positive?

      render_social_share_buttons(enabled_services, title, args)
    end

    def render_social_share_buttons(services, title, args)
      services.map do |service|
        render_social_share_button(service, title, args)
      end.join.html_safe
    end

    def render_social_share_button(service, title, args)
      uri = service.formatted_share_uri(title, args)
      return unless uri

      data = service.optional_args.reverse_merge(
        "site" => service.name.downcase,
        "external-link" => "text-only",
        "external-domain-link" => false
      )

      link_to(
        uri,
        rel: "nofollow noopener noreferrer",
        target: "_blank",
        data:,
        title: t("decidim.shared.share_modal.share_to", service: service.name)
      ) do
        content_tag(:span, render_social_share_icon(service), class: "icon") +
          content_tag(:span, service.name, class: "text")
      end
    end

    def render_social_share_icon(service, options = {})
      if service.icon.include? ".svg"
        image_tag service.icon_path, options.merge(alt: t("decidim.shared.share_modal.share_to", service: service.name))
      else
        icon(service.icon, options.merge(ignore_missing: true))
      end
    end

    private

    def enabled_services
      Decidim.config.social_share_services.map { |service_name| Decidim.social_share_services_registry.find(service_name) }
    end
  end
end
