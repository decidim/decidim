# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization appearance.
    class UpdateOrganizationAppearance < Decidim::Commands::UpdateResource
      fetch_file_attributes :logo, :favicon, :official_img_footer

      fetch_form_attributes :cta_button_path, :cta_button_text, :official_url,
                            :enable_omnipresent_banner, :omnipresent_banner_url,
                            :omnipresent_banner_title, :omnipresent_banner_short_description

      private

      def attributes
        super
          .merge(colors_attributes)
          .delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
          .tap do |attributes|
            attributes[:header_snippets] = form.header_snippets if Decidim.enable_html_header_snippets
          end
      end

      def colors_attributes
        {
          colors: {
            primary: form.primary_color,
            secondary: form.secondary_color,
            tertiary: form.tertiary_color
          }.compact_blank
        }
      end
    end
  end
end
