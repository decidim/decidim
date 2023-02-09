# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include Decidim::TwitterSearchHelper
      include ParticipatoryProcessHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      alias process model
      alias current_participatory_space model

      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
      end

      private

      def step_title
        translated_attribute process.active_step&.title
      end

      def hashtag
        @hashtag ||= decidim_html_escape(process.hashtag) if process.hashtag.present?
      end

      def nav_items
        return super if (nav_items = try(:process_nav_items, process)).blank?

        nav_items
      end
    end
  end
end
