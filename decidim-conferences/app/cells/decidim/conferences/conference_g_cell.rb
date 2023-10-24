# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the Grid (:g) conference card
    # for a given instance of a Conference
    class ConferenceGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::Conferences::Engine.routes.url_helpers.conference_path(model)
      end

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end

      def metadata_cell
        "decidim/conferences/conference_metadata"
      end
    end
  end
end
