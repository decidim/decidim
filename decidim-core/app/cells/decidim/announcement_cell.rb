# frozen_string_literal: true

module Decidim
  # This cell renders an announcement
  # the `model` is spected to be a Hash with two keys:
  #  `announcement` is mandatory, its the message to show
  #  `callout_class` is optional, the css class modifier
  #
  # {
  #   announcement: { ... },
  #   callout_class: "warning"
  # }
  #
  class AnnouncementCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def show
      return unless announcement.presence

      render :show
    end

    private

    def has_title?
      announcement.is_a?(Hash) && announcement.has_key?(:title)
    end

    def callout_class
      options[:callout_class] ||= "secondary"
    end

    def announcement
      model
    end

    def clean_title
      clean(announcement[:title])
    end

    def clean_body
      Array(announcement[:body]).map { |paragraph| tag.p(clean(paragraph)) }.join("")
    end

    def clean_announcement
      clean(announcement)
    end

    def clean(value)
      decidim_sanitize(translated_attribute(value))
    end
  end
end
