# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module MailerHelper
    # Transforms relative image URLs in HTML content to absolute URLs using the provided host.
    # This is used in emails (newsletters and notifications) to ensure images display correctly
    # in email clients. Only the URL origin is used, because the Decidim root URL is
    # locale-scoped and image paths should not include a locale segment.
    #
    # @param content [String] - HTML content with img tags
    # @param host [String] - the Decidim::Organization host to use for the URL origin
    #
    # @return [String] - the content with transformed image URLs
    def decidim_transform_image_urls(content, host)
      return content if host.blank? || content.blank?

      origin = image_url_origin(host)

      content.gsub(/src\s*=\s*(['"])([^'"]*)\1/) do
        quote = Regexp.last_match(1)
        src_value = Regexp.last_match(2)

        if src_value.blank? || src_value.start_with?("http://", "https://", "data:", "//", "cid:")
          %(src=#{quote}#{src_value}#{quote})
        else
          normalized_src = src_value.start_with?("/") ? src_value : "/#{src_value}"
          %(src=#{quote}#{origin}#{normalized_src}#{quote})
        end
      end
    end

    private

    def image_url_origin(host)
      return Decidim.storage_cdn_host.chomp("/") if Decidim.storage_cdn_host.present?

      uri = URI.parse(Decidim::EngineRouter.new("decidim", {}).root_url(host:))
      port = uri.port.present? && [80, 443].exclude?(uri.port) ? ":#{uri.port}" : ""
      "#{uri.scheme}://#{uri.host}#{port}"
    end
  end
end
