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

      attribute :header_snippets, String
      attribute :highlighted_content_banner_enabled, Boolean, default: false
      attribute :highlighted_content_banner_action_url, String
      attribute :highlighted_content_banner_image
      attribute :remove_highlighted_content_banner_image, Boolean, default: false

      translatable_attribute :highlighted_content_banner_title, String
      translatable_attribute :highlighted_content_banner_short_description, Decidim::Attributes::RichText
      translatable_attribute :highlighted_content_banner_action_title, String
      translatable_attribute :highlighted_content_banner_action_subtitle, String

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

      alias organization current_organization

      private

      def highlighted_content_banner_enabled?
        highlighted_content_banner_enabled
      end

      def highlighted_content_banner_image_is_changed?
        highlighted_content_banner_enabled? &&
          current_organization.highlighted_content_banner_image.blank?
      end
    end
  end
end
