# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the Grid (:g) initiative card
    # for a given instance of an Initiative
    class InitiativeGCell < Decidim::CardGCell
      private

      def resource_path
        if resource.state == "created" || resource.state == "validating"
          Decidim::Initiatives::Engine.routes.url_helpers.load_initiative_draft_create_initiative_index_path(initiative_id: resource.id, locale: current_locale)
        else
          Decidim::Initiatives::Engine.routes.url_helpers.initiative_path(model, locale: current_locale)
        end
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
