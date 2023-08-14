# frozen_string_literal: true

module Decidim
  module ExternalDomainHelper
    def highlight_domain
      highlighted_domain = [
        external_url.host,
        (external_url.port && [80, 443].include?(external_url.port) ? "" : ":#{external_url.port}")
      ].join

      path = [
        external_url.path,
        (external_url.query ? "?#{external_url.query}" : ""),
        (external_url.fragment ? "##{external_url.fragment}" : "")
      ].join

      tag.div do
        content_tag(:span, "#{external_url.scheme}://") +
          content_tag(:span, highlighted_domain, class: "text-alert") +
          content_tag(:span, path)
      end
    end
  end
end
