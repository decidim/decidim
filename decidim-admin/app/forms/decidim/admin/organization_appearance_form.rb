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

      translatable_attribute :description, String
      translatable_attribute :welcome_text, String

      validates :official_img_header,
                :official_img_footer,
                :logo,
                file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                file_content_type: { allow: ["image/jpeg", "image/png"] }
    end
  end
end
