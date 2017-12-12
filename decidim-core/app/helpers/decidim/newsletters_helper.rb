# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module NewslettersHelper
    def parse_interpolations(id, content, user)
      host = "#{user.organization.host}.to_s"
      campaign = "newsletter_#{id}"

      links = content.scan(/href\s*=\s*"([^"]*)"/)

      links.each do |link|
        link_replaced = link.first + "?utm_source=" + host + "&utm_campaign=" + campaign
        content = content.gsub(/href\s*=\s*"([^"]*#{link.first})"/, "href=" + link_replaced)
      end
      content.gsub("%{name}", user.name)
    end
  end
end
