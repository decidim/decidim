# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Medium (:m) process card
    # for an given instance of a Process
    class ProcessMCell < Decidim::CardMCell
      private

      def has_image?
        true
      end

      def resource_image_path
        model.hero_image.url
      end

      def base_card_class
        "card--process"
      end

      def statuses
        [:creation_date, :follow]
      end

      def resource_icon
        icon "processes", class: "icon--big"
      end

      def start_date
        model.start_date
      end

      def end_date
        model.end_date.to_date
      end
    end
  end
end
