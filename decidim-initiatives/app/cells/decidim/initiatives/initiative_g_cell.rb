# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the Grid (:g) initiative card
    # for a given instance of an Initiative
    class InitiativeGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::Initiatives::Engine.routes.url_helpers.initiative_path(model)
      end

      def has_image?
        image.present?
      end

      def image
        @image ||= model.attachments.find(&:image?)
      end

      def resource_image_path
        image.url if has_image?
      end

      def metadata_cell
        "decidim/initiatives/initiative_metadata_g"
      end
    end
  end
end
