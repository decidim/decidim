# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization appearance.
    class UpdateOrganizationAppearance < Decidim::Commands::UpdateResource
      include ::Decidim::AttachmentAttributesMethods

      fetch_form_attributes :cta_button_path, :cta_button_text, :description, :official_url,
                            :highlighted_content_banner_enabled, :highlighted_content_banner_action_url,
                            :highlighted_content_banner_title, :highlighted_content_banner_short_description,
                            :highlighted_content_banner_action_title,
                            :highlighted_content_banner_action_subtitle, :enable_omnipresent_banner, :omnipresent_banner_url,
                            :omnipresent_banner_title, :omnipresent_banner_short_description

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        begin
          update_resource
          broadcast(:ok, resource)
        rescue ActiveRecord::RecordInvalid
          image_fields.each do |field|
            form.errors.add(field, resource.errors[field]) if resource.errors.include? field
          end
          broadcast(:invalid)
        end
      end

      private

      def image_fields
        [:logo, :highlighted_content_banner_image, :favicon, :official_img_footer]
      end

      def attributes
        super
          .merge(attachment_attributes(*image_fields))
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
            tertiary: form.tertiary_color,
            success: form.success_color,
            warning: form.warning_color,
            alert: form.alert_color
          }.compact_blank
        }
      end
    end
  end
end
