# frozen_string_literal: true

module Decidim
  # This cell renders an announcement
  #
  # The `model` is expected to be a Hash with two keys:
  #   - `body` is mandatory, its the message to show
  #   - `title` is mandatory, a title to show
  #
  # {
  #   title: "...", # mandatory
  #   body: "..." # mandatory
  # }
  #
  # It can also receive a single value to show as text. It can either be a String
  # or a value accepted by the `translated_attribute` method.
  #
  # As options, the cell accepts a Hash with these keys:
  #   - `callout_class`: The Css class to apply. Default to `"secondary"`
  #
  class AnnouncementWithTruncateCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    TRUNCATE_LENGTH = 200

    def show
      return if clean_body.blank? && clean_announcement.blank?

      render :show
    end

    private

    def has_truncated?
      if has_title?
        clean_body.length > TRUNCATE_LENGTH
      else
        clean_announcement.length > TRUNCATE_LENGTH
      end
    end

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

    def body
      return announcement.presence unless announcement.is_a?(Hash)

      announcement[:body].presence
    end

    def clean_body(truncate_text: false)
      return unless body

      Array(body).map { |paragraph| tag.p(clean(paragraph, truncate_text)) }.join
    end

    def clean_announcement(truncate_text: false)
      return unless announcement

      clean(announcement, truncate_text)
    end

    def clean(value, truncate_text)
      translated_value = translated_attribute(value)
      translated_value = truncate(translated_value, length: TRUNCATE_LENGTH, escape: false) if truncate_text

      decidim_sanitize(translated_value)
    end
  end
end
