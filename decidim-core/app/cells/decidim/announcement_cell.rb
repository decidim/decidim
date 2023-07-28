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
  #   - `callout_class`: The Css class to apply
  #
  class AnnouncementCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def show
      return if blank_content?

      render :show
    end

    def blank_content?
      @blank_content ||= clean_body.blank? && clean_announcement.blank?
    end

    private

    def has_title?
      announcement.is_a?(Hash) && announcement.has_key?(:title)
    end

    def text
      has_title? ? clean_body : clean_announcement
    end

    def callout_class
      options[:callout_class]
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

    def truncate?
      return false unless options.has_key? :truncate

      options[:truncate]
    end

    def clean_body
      return unless body

      Array(body).map { |paragraph| tag.p(clean(paragraph)) }.join
    end

    def clean_announcement
      clean(announcement)
    end

    def clean(value)
      decidim_sanitize_admin(translated_attribute(value))
    end
  end
end
