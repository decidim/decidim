# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to update the current organization appearance from the admin
    # dashboard.
    #
    class OrganizationAppearanceForm < Form
      include TranslatableAttributes
      include Decidim::HasUploadValidations

      mimic :organization

      attribute :logo
      attribute :remove_logo, Boolean, default: false
      attribute :favicon
      attribute :remove_favicon, Boolean, default: false
      attribute :official_img_footer
      attribute :remove_official_img_footer, Boolean, default: false
      attribute :official_url
      attribute :header_snippets, String
      attribute :cta_button_path, String
      attribute :enable_omnipresent_banner, Boolean, default: false
      attribute :omnipresent_banner_url, String

      attribute :primary_color, String
      attribute :secondary_color, String
      attribute :tertiary_color, String

      translatable_attribute :cta_button_text, String
      translatable_attribute :omnipresent_banner_title, String
      translatable_attribute :omnipresent_banner_short_description, String

      validates :cta_button_path, format: { with: %r{\A[a-zA-Z]+[a-zA-Z0-9\-_/]+\z} }, allow_blank: true
      validates :official_img_footer,
                :logo,
                passthru: { to: Decidim::Organization }

      validates :omnipresent_banner_url, url: true, presence: true, if: :enable_omnipresent_banner?
      validates :omnipresent_banner_title, translatable_presence: true, if: :enable_omnipresent_banner?
      validates :omnipresent_banner_short_description, translatable_presence: true, if: :enable_omnipresent_banner?

      alias organization current_organization

      private

      def enable_omnipresent_banner?
        enable_omnipresent_banner
      end
    end
  end
end
