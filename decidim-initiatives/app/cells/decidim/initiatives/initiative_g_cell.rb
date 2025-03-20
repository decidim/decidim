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

      def image
        @image ||= model.attachments.find(&:image?)
      end

      def resource_image_url
        return if image.blank?

        image.url
      end

      def metadata_cell
        "decidim/initiatives/initiative_metadata_g"
      end
    end
  end
end
