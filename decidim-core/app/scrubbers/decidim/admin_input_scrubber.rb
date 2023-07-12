# frozen_string_literal: true

module Decidim
  # Use this class as a scrubber to sanitize admin user input. The default
  # scrubbed provided by Rails does not allow `iframe`s, and we are using
  # them to embed videos, so we need to provide a whole new scrubber.
  #
  # Example:
  #
  #    sanitize(@page.body, scrubber: Decidim::AdminInputScrubber.new)
  #
  # Lists of default tags and attributes are extracted from
  # https://stackoverflow.com/a/35073814/2110884.
  class AdminInputScrubber < UserInputScrubber
    private

    DECIDIM_ALLOWED_TAGS = %w(img video audio source comment iframe).freeze

    def custom_allowed_attributes
      super + %w(frameborder allowfullscreen) - %w(onerror)
    end

    def custom_allowed_tags
      super + DECIDIM_ALLOWED_TAGS
    end
  end
end
