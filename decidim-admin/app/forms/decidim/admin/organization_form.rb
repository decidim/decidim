# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to update the current organization from the admin
    # dashboard.
    #
    class OrganizationForm < Form
      include TranslatableAttributes

      mimic :organization

      attribute :name, String
      attribute :reference_prefix, String
      attribute :twitter_handler, String
      attribute :facebook_handler, String
      attribute :instagram_handler, String
      attribute :youtube_handler, String
      attribute :github_handler, String
      attribute :default_locale, String
      attribute :homepage_image
      attribute :remove_homepage_image
      attribute :logo
      attribute :remove_logo
      attribute :favicon
      attribute :remove_favicon
      attribute :official_url
      attribute :official_img_header
      attribute :remove_official_img_header
      attribute :official_img_footer
      attribute :remove_official_img_footer
      attribute :show_statistics
      attribute :header_snippets, String

      translatable_attribute :description, String
      translatable_attribute :welcome_text, String

      validates :name, presence: true
      validates :default_locale, presence: true
      validates :default_locale, inclusion: { in: :available_locales }

      validates :official_img_header,
                file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                file_content_type: { allow: ["image/jpeg", "image/png"] }
      validates :official_img_footer,
                file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                file_content_type: { allow: ["image/jpeg", "image/png"] }

      private

      def available_locales
        current_organization.available_locales
      end
    end
  end
end
