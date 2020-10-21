# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conference media link from the admin dashboard.
      class MediaLinkForm < Form
        include TranslatableAttributes

        mimic :conference_media_link

        translatable_attribute :title, String

        attribute :link, String
        attribute :date, Decidim::Attributes::LocalizedDate
        attribute :weight, Integer, default: 0

        validates :title, :date, :link, presence: true
        validate :link_format

        def link
          return if super.blank?

          return "http://#{super}" unless super.match?(%r{\A(http|https)://}i)

          super
        end

        private

        def link_format
          return if link.blank?

          uri = URI.parse(link)
          errors.add :link, :invalid if !uri.is_a?(URI::HTTP) || uri.host.nil?
        rescue URI::InvalidURIError
          errors.add :link, :invalid
        end
      end
    end
  end
end
