# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the Medium (:m) conference card
    # for an given instance of an Conference
    class ConferenceMCell < Decidim::CardMCell
      include Decidim::ViewHooksHelper

      # Needed for the view hooks
      def current_participatory_space
        model
      end

      def show
        render
      end

      private

      def title
        decidim_html_escape(super)
      end

      def has_image?
        true
      end

      def resource_path
        Decidim::Conferences::Engine.routes.url_helpers.conference_path(model)
      end

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end

      def statuses
        [:creation_date, :follow]
      end

      def resource_icon
        icon "conferences", class: "icon--big"
      end
    end
  end
end
