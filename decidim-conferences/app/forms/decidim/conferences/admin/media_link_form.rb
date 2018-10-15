# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conference media link from the admin dashboard.
      class MediaLinkForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String

        mimic :conference_speaker

        attribute :link, String
        attribute :weight, Integer

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
