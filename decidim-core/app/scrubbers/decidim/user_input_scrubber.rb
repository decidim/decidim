# frozen_string_literal: true

module Decidim
  # Use this class as a scrubber to sanitize participant user input.
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

    RESTRICTED_TAGS = %w(
      area
      article
      aside
      audio
      button
      canvas
      fieldset
      figcaption
      figure
      font
      footer
      form
      header
      img
      input
      label
      legend
      main
      map
      menu
      optgroup
      option
      output
      select
      textarea
      video
    ).freeze

    def custom_allowed_attributes
      Loofah::HTML5::SafeList::ALLOWED_ATTRIBUTES
    end

    def custom_allowed_tags
      Loofah::HTML5::SafeList::ACCEPTABLE_ELEMENTS - RESTRICTED_TAGS
    end
  end
end
