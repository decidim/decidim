# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module SanitizeHelper
    def self.included(base)
      base.include ActionView::Helpers::SanitizeHelper
    end

    # Public: It sanitizes a user-inputted string with the
    # `Decidim::UserInputScrubber` scrubber, so that video embeds work
    # as expected. Uses Rails' `sanitize` internally.
    #
    # html - A string representing user-inputted HTML.
    #
    # Returns an HTML-safe String.
    def decidim_sanitize(html, options = {})
      if options[:strip_tags]
        strip_tags sanitize(html, scrubber: Decidim::UserInputScrubber.new)
      else
        sanitize(html, scrubber: Decidim::UserInputScrubber.new)
      end
    end

    def decidim_html_escape(text)
      ERB::Util.unwrapped_html_escape(text.to_str)
    end

    def decidim_url_escape(text)
      decidim_html_escape(text).sub(/^javascript:/, "")
    end

    def csv_sanitize(value)
      # rubocop:disable Style/AndOr
      return value unless value.instance_of?(String) and invalid_first_chars.include?(value.first)

      # rubocop:enable Style/AndOr
      value.prepend("'")
    end

    def invalid_first_chars
      %w(= + - @)
    end
  end
end
