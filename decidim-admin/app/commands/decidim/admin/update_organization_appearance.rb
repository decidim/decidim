# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization appearance.
    class UpdateOrganizationAppearance < Decidim::Commands::UpdateResource
      fetch_file_attributes :logo, :highlighted_content_banner_image, :favicon, :official_img_footer

      fetch_form_attributes :official_url,
                            :highlighted_content_banner_enabled, :highlighted_content_banner_action_url,
                            :highlighted_content_banner_title, :highlighted_content_banner_short_description,
                            :highlighted_content_banner_action_title,
                            :highlighted_content_banner_action_subtitle, :enable_omnipresent_banner, :omnipresent_banner_url,
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
