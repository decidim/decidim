# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module NewslettersHelper
    def parse_interpolations(content, user = nil, id = nil)
      if id.present? && user.present?
        host = user.organization.host.to_s
        campaign = "newsletter_#{id}"

        links = content.scan(/href\s*=\s*"([^"]*)"/)

        links.each do |link|
          link_replaced = link.first + utm_codes(host, campaign)
          content = content.gsub(/href\s*=\s*"([^"]*#{link.first})"/, %(href="#{link_replaced}"))
        end
      end

      if user.present?
        content.gsub("%{name}", user.name)
      else
        content.gsub("%{name}", "")
      end
    end

    def custom_url_for_mail_root(organization, newsletter_id = nil)
      if newsletter_id.present?
        decidim.root_url(host: organization.host) + utm_codes(organization.host, newsletter_id.to_s)
      else
        decidim.root_url(host: organization.host)
      end
    end

    def utm_codes(host, newsletter_id)
      "?utm_source=" + host + "&utm_campaign=" + newsletter_id
    end
  end
end
