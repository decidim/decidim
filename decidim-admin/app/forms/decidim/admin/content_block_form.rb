# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to configure a content block from the admin panel.
    #
    class ContentBlockForm < Decidim::Form
      include TranslatableAttributes

      mimic :content_block

      attribute :settings, Object
      attribute :images, Hash

      validate :validate_settings

      def map_model(model)
        self.images = model.images_container
      end

      def settings?
        return false unless settings.respond_to?(:manifest)

        settings.manifest.attributes.any?
      end

      private

      def validate_settings
        coerce_settings if settings.respond_to?(:to_h) && !settings.respond_to?(:valid?)

        return unless settings.respond_to?(:valid?)
        return if settings.valid?

        settings.errors.each do |error|
          errors.add(:settings, error.message)
        end
      end

      def coerce_settings
        content_block = context[:content_block]
        return unless content_block

        self.settings = content_block.manifest.settings.schema.new(
          settings.to_h,
          content_block.organization.default_locale
        )
      end
    end
  end
end
