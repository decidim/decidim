# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include ParticipatoryProcessHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      alias process model

      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
      end

      private

      def step_title
        translated_attribute process.active_step&.title
      end

      def nav_items_method = :process_nav_items
    end
  end
end
