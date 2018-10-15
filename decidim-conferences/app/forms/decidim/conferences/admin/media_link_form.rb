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

        validate :link_format

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
