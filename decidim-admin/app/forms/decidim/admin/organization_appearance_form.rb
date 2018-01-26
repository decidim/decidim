# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to update the current organization appearance from the admin
    # dashboard.
    #
    class OrganizationAppearanceForm < Form
      include TranslatableAttributes

      mimic :organization_appearance

      attribute :homepage_image
      attribute :remove_homepage_image
      attribute :logo
      attribute :remove_logo
      attribute :favicon
      attribute :remove_favicon
      attribute :official_img_header
      attribute :remove_official_img_header
      attribute :official_img_footer
      attribute :remove_official_img_footer
      attribute :official_url
      attribute :show_statistics, Boolean
      attribute :header_snippets, String
      attribute :cta_button_path, String
      attribute :highlighted_content_banner_enabled, Boolean, default: false
      attribute :highlighted_content_banner_action_url, String
      attribute :highlighted_content_banner_image
      attribute :remove_highlighted_content_banner_image

      translatable_attribute :cta_button_text, String
      translatable_attribute :description, String
      translatable_attribute :welcome_text, String
      translatable_attribute :highlighted_content_banner_title, String
      translatable_attribute :highlighted_content_banner_short_description, String
      translatable_attribute :highlighted_content_banner_action_title, String
      translatable_attribute :highlighted_content_banner_action_subtitle, String

      validates :cta_button_path, format: { with: %r{\A[a-zA-Z]+[a-zA-Z0-9\-/]+\z} }, allow_blank: true
      validates :official_img_header,
                :official_img_footer,
                :homepage_image,
                :logo,
                file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                file_content_type: { allow: ["image/jpeg", "image/png"] }

      validates :highlighted_content_banner_action_url, presence: true, if: :highlighted_content_banner_enabled?
      validates :highlighted_content_banner_image,
                presence: true,
                file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                file_content_type: { allow: ["image/jpeg", "image/png"] },
                if: :highlighted_content_banner_enabled?

      validates :highlighted_content_banner_title,
                translatable_presence: true,
                if: :highlighted_content_banner_enabled?

      validates :highlighted_content_banner_short_description,
                translatable_presence: true,
                if: :highlighted_content_banner_enabled?

      validates :highlighted_content_banner_action_title,
                translatable_presence: true,
                if: :highlighted_content_banner_enabled?

      def highlighted_content_banner_enabled?
        highlighted_content_banner_enabled
      end
    end
  end
end
