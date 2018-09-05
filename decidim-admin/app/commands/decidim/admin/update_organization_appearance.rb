# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization appearance.
    class UpdateOrganizationAppearance < Rectify::Command
      # Public: Initializes the command.
      #
      # organization - The Organization that will be updated.
      # form - A form object with the params.
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        begin
          update_organization
          broadcast(:ok, organization)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:official_img_header, organization.errors[:official_img_header]) if organization.errors.include? :official_img_header
          form.errors.add(:official_img_footer, organization.errors[:official_img_footer]) if organization.errors.include? :official_img_footer
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form, :organization

      def update_organization
        @organization = Decidim.traceability.update!(
          organization,
          form.current_user,
          attributes
        )
      end

      def attributes
        appearance_attributes
          .merge(highlighted_content_banner_attributes)
          .merge(omnipresent_banner_attributes)
          .tap do |attributes|
            attributes[:header_snippets] = form.header_snippets if Decidim.enable_html_header_snippets
          end
      end

      def appearance_attributes
        {
          cta_button_path: form.cta_button_path,
          cta_button_text: form.cta_button_text,
          description: form.description,
          logo: form.logo,
          remove_logo: form.remove_logo,
          favicon: form.favicon,
          remove_favicon: form.remove_favicon,
          official_img_header: form.official_img_header,
          remove_official_img_header: form.remove_official_img_header,
          official_img_footer: form.official_img_footer,
          remove_official_img_footer: form.remove_official_img_footer,
          official_url: form.official_url,
          show_statistics: form.show_statistics
        }
      end

      def highlighted_content_banner_attributes
        {
          highlighted_content_banner_enabled: form.highlighted_content_banner_enabled,
          highlighted_content_banner_action_url: form.highlighted_content_banner_action_url,
          highlighted_content_banner_image: form.highlighted_content_banner_image,
          remove_highlighted_content_banner_image: form.remove_highlighted_content_banner_image,
          highlighted_content_banner_title: form.highlighted_content_banner_title,
          highlighted_content_banner_short_description: form.highlighted_content_banner_short_description,
          highlighted_content_banner_action_title: form.highlighted_content_banner_action_title,
          highlighted_content_banner_action_subtitle: form.highlighted_content_banner_action_subtitle
        }
      end

      def omnipresent_banner_attributes
        {
          enable_omnipresent_banner: form.enable_omnipresent_banner,
          omnipresent_banner_url: form.omnipresent_banner_url,
          omnipresent_banner_short_description: form.omnipresent_banner_short_description,
          omnipresent_banner_title: form.omnipresent_banner_title
        }
      end
    end
  end
end
