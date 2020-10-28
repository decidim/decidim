# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render links with utm codes, and replaced name
  module NewslettersHelper
    # If the newsletter body there are some links and the Decidim.track_newsletter_links = true
    # it will be replaced with the utm_codes method described below.
    # for example transform "https://es.lipsum.com/" to "https://es.lipsum.com/?utm_source=localhost&utm_campaign=newsletter_11"
    # And replace "%{name}" on the subject or content of newsletter to the user Name
    # for example transform "%{name}" to "User Name"
    def parse_interpolations(content, user = nil, id = nil)
      if Decidim.config.track_newsletter_links && id.present? && user.present?
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

    # this method is used to generate the root link on mail with the utm_codes
    # If the newsletter_id is nil, it returns the root_url
    def custom_url_for_mail_root(organization, newsletter_id = nil)
      if newsletter_id.present?
        decidim.root_url(host: organization.host) + utm_codes(organization.host, newsletter_id.to_s)
      else
        decidim.root_url(host: organization.host)
      end
    end

    # Method to specify the utm_codes.
    # You can change or add utm_codes for track
    def utm_codes(host, newsletter_id)
      "?utm_source=#{host}&utm_campaign=#{newsletter_id}"
    end
  end
end
