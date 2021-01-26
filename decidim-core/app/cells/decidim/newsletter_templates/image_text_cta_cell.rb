# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NewsletterTemplates
    class ImageTextCtaCell < BaseCell
      def show
        render :show
      end

      def introduction
        parse_interpolations(uninterpolated_introduction, recipient_user, newsletter.id)
      end

      def uninterpolated_introduction
        translated_attribute(model.settings.introduction)
      end

      def body
        parse_interpolations(uninterpolated_body, recipient_user, newsletter.id)
      end

      def uninterpolated_body
        translated_attribute(model.settings.body)
      end

      def has_cta?
        cta_text.present? && cta_url.present?
      end

      def cta_text
        parse_interpolations(
          translated_attribute(model.settings.cta_text),
          recipient_user,
          newsletter.id
        )
      end

      def cta_url
        translated_attribute(model.settings.cta_url)
      end

      def has_main_image?
        main_image_url.present?
      end

      def main_image
        image_tag main_image_url
      end

      def main_image_url
        newsletter.template.images_container.main_image.url
      end

      def organization_primary_color
        organization.colors["primary"]
      end
    end
  end
end
