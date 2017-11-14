# frozen_string_literal: true

module Decidim
  # Use this class as a scrubber to sanitize user input. The default
  # scrubbed provided by Rails does not allow `iframe`s, and we're using
  # them to embed videos, so we need to provide a whole new scrubber.
  #
  # Example:
  #
  #    sanitize(@page.body, scrubber: Decidim::UserInputScrubber.new)
  #
  # Lists of default tags and attributes are extracted from
  # https://stackoverflow.com/a/35073814/2110884.
  class UserInputScrubber < Rails::Html::PermitScrubber
    def initialize
      super
      self.tags = custom_allowed_tags
      self.attributes = custom_allowed_attributes
    end

    private

    def custom_allowed_attributes
      Loofah::HTML5::WhiteList::ALLOWED_ATTRIBUTES + %w(frameborder allowfullscreen)
    end

    def custom_allowed_tags
      Loofah::HTML5::WhiteList::ALLOWED_ELEMENTS_WITH_LIBXML2 + %w(iframe)
    end
  end
end
