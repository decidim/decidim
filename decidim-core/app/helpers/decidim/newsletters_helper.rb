# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render links with utm codes, and replaced name
  module NewslettersHelper
    # If the newsletter body there are some links and the Decidim.track_newsletter_links = true
    # it will be replaced with the utm_codes method described below.
    # for example transform "https://es.lipsum.com/" to "https://es.lipsum.com/?utm_source=localhost&utm_campaign=newsletter_11"
    # And replace "%{name}" on the subject or content of newsletter to the user Name
    # for example transform "%{name}" to "User Name"
    #
    # @param content [String] - the string to convert
    # @param user [Decidim::User] - the user to replace
    # @param id [Integer] - the id of the newsletter to change
    #
    # @return [String] - the content converted
    def parse_interpolations(content, user = nil, id = nil)
      host = user&.organization&.host&.to_s

      content = interpret_name(content, user)
      content = track_newsletter_links(content, id, host)
      transform_image_urls(content, host)
    end

    # this method is used to generate the root link on mail with the utm_codes
    # If the newsletter_id is nil, it returns the root_url
    #
    # @param organization [Decidim::Organization] - the Organization of this newsletter
    # @param newsletter_id [Integer] - the id of the newsletter
    #
    # @return [String] - the root_url converted
    #
    def custom_url_for_mail_root(organization, newsletter_id = nil)
      decidim = EngineRouter.new("decidim", {})
      if newsletter_id.present?
        decidim.root_url(host: organization.host) + utm_codes(organization.host, newsletter_id.to_s)
      else
        decidim.root_url(host: organization.host)
      end
    end

    private

    # Method to specify the utm_codes.
    # You can change or add utm_codes for track
    #
    # @param host [String] - the Decidim::Organization host add to the URL
    # @param newsletter_id [String] - the ID of the newsletter
    #
    # @return [String] - the UTM codes to be added
    #
    def utm_codes(host, newsletter_id)
      "?utm_source=#{host}&utm_campaign=#{newsletter_id}"
    end

    # Interpret placeholder '%{name}' and replace by the user name
    # If user is not define, it returns content with blank instead of the placeholder
    #
    # @param content [String] - the string to convert
    # @param user [Decidim::User] - the user to replace
    #
    # @return [String] - the content converted
    #
    def interpret_name(content, user)
      return content.gsub("%{name}", "") if user.blank?

      content.gsub("%{name}", user.name)
    end

    # Find each img HTML tag with relative path in src attribute
    # For each URL, prepends the decidim.root_url
    #   If host is not defined it returns full content
    #
    # @param content [String] - the string to convert
    # @param host [String] - the Decidim::Organization host to replace
    #
    # @return [String] - the content converted
    #
    def transform_image_urls(content, host)
      return content if host.blank?

      content.scan(/src\s*=\s*"([^"]*)"/).each do |src|
        root_url = decidim.root_url(host:)[0..-2]
        src_replaced = "#{root_url}#{src.first}"
        content = content.gsub(/src\s*=\s*"([^"]*#{src.first})"/, %(src="#{src_replaced}"))
      end

      content
    end

    # Add tracking query params to each links
    #
    # @param content [String] - the string to convert
    # @param id [Integer] - the id of the newsletter
    # @param host [String] - the Decidim::Organization host
    #
    # @return [String] - the content converted
    #
    def track_newsletter_links(content, id, host)
      return content unless Decidim.config.track_newsletter_links
      return content if id.blank?
      return content if host.blank?

      campaign = "newsletter_#{id}"
      links = content.scan(/href\s*=\s*"([^"]*)"/)

      links.each do |link|
        link_replaced = link.first + utm_codes(host, campaign)
        content = content.gsub(/href\s*=\s*"([^"]*#{link.first})"/, %(href="#{link_replaced}"))
      end

      content
    end
  end
end
