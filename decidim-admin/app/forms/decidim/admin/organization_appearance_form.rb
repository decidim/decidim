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
      attribute :highlighted_content_banner_enabled, Boolean, default: false
      attribute :highlighted_content_banner_action_url, String
      attribute :highlighted_content_banner_image
      attribute :remove_highlighted_content_banner_image, Boolean, default: false
      attribute :enable_omnipresent_banner, Boolean, default: false
      attribute :omnipresent_banner_url, String

      attribute :primary_color, String
      attribute :secondary_color, String
      attribute :tertiary_color, String

      translatable_attribute :cta_button_text, String
      translatable_attribute :highlighted_content_banner_title, String
      translatable_attribute :highlighted_content_banner_short_description, Decidim::Attributes::RichText
      translatable_attribute :highlighted_content_banner_action_title, String
      translatable_attribute :highlighted_content_banner_action_subtitle, String
      translatable_attribute :omnipresent_banner_title, String
      translatable_attribute :omnipresent_banner_short_description, String

      validates :cta_button_path, format: { with: %r{\A[a-zA-Z]+[a-zA-Z0-9\-_/]+\z} }, allow_blank: true
      validates :official_img_footer,
                :logo,
                passthru: { to: Decidim::Organization }

      validates :highlighted_content_banner_action_url, url: true, presence: true, if: :highlighted_content_banner_enabled?
      validates :highlighted_content_banner_image,
                presence: true,
                passthru: { to: Decidim::Organization },
                if: :highlighted_content_banner_image_is_changed?

      validates :highlighted_content_banner_title,
                translatable_presence: true,
                if: :highlighted_content_banner_enabled?

      validates :highlighted_content_banner_short_description,
                translatable_presence: true,
                if: :highlighted_content_banner_enabled?

      validates :highlighted_content_banner_action_title,
                translatable_presence: true,
                if: :highlighted_content_banner_enabled?

      validates :omnipresent_banner_url, url: true, presence: true, if: :enable_omnipresent_banner?
      validates :omnipresent_banner_title, translatable_presence: true, if: :enable_omnipresent_banner?
      validates :omnipresent_banner_short_description, translatable_presence: true, if: :enable_omnipresent_banner?

      alias organization current_organization

      private

      def highlighted_content_banner_enabled?
        highlighted_content_banner_enabled
      end

      def enable_omnipresent_banner?
        enable_omnipresent_banner
      end

      def highlighted_content_banner_image_is_changed?
        highlighted_content_banner_enabled? &&
          current_organization.highlighted_content_banner_image.blank?
      end
    end
  end
end
