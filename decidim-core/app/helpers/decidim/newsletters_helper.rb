# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module NewslettersHelper
    require 'uri'

    def link_utm_codes(id, link, organization)
      host = "#{organization.host}"
      campaign = "newsletter_#{id}"
      link_replaced = link + "?utm_source=" + host + "&utm_campaign=" + campaign
    end

    def parse_interpolations(id, content, user)
      links= URI.extract(content)
      host = "#{user.organization.host}"
      campaign = "newsletter_#{id}"
      links.each do |link|
        link_replaced = link + "?utm_source=" + host + "&utm_campaign=" + campaign
        content = content.gsub(link, link_replaced)
      end
      content.gsub("%{name}", user.name)

    end
  end
end
