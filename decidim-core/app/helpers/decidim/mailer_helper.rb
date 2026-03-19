# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module MailerHelper
    # Transforms relative image URLs in HTML content to absolute URLs using the provided host.
    # This is used in emails (newsletters and notifications) to ensure images display correctly
    # in email clients.
    #
    # @param content [String] - HTML content with img tags
    # @param host [String] - the Decidim::Organization host to use for the root URL
    #
    # @return [String] - the content with transformed image URLs
    def decidim_transform_image_urls(content, host)
      return content if host.blank? || content.blank?

      root_url = if Decidim.storage_cdn_host.present?
                   Decidim.storage_cdn_host.chomp("/")
                 else
                   Decidim::EngineRouter.new("decidim", {}).root_url(host:).chomp("/")
                 end

      content.gsub(/src\s*=\s*(['"])([^'"]*)\1/) do
        quote = Regexp.last_match(1)
        src_value = Regexp.last_match(2)

        if src_value.blank? || src_value.start_with?("http://", "https://", "data:", "//", "cid:")
          %(src=#{quote}#{src_value}#{quote})
        else
          normalized_src = src_value.start_with?("/") ? src_value : "/#{src_value}"
          %(src=#{quote}#{root_url}#{normalized_src}#{quote})
        end
      end
    end
  end
end
