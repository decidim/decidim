# frozen_string_literal: true

module Decidim
  class AnnouncementComponent < Decidim::BaseComponent
    def initialize(announcement, options = {})
      @announcement = announcement
      @options = options
    end

    private

    attr_reader :announcement, :options

    def render?
      text.present?
    end

    def has_title?
      announcement.is_a?(Hash) && announcement.has_key?(:title)
    end

    def clean_title
      clean(announcement[:title])
    end

    def css_class
      return unless options[:callout_class]

      options[:callout_class]
    end

    def clean(value)
      if options[:raw]
        translated_attribute(value)
      else
        decidim_sanitize_admin(translated_attribute(value))
      end
    end

    def text
      has_title? ? clean_body : clean_announcement
    end

    def clean_body
      return unless body

      Array(body).map { |paragraph| tag.p(clean(paragraph)) }.join.html_safe
    end

    def body
      return announcement.presence unless announcement.is_a?(Hash)

      announcement[:body].presence
    end

    def clean_announcement
      clean(announcement)
    end
  end
end
