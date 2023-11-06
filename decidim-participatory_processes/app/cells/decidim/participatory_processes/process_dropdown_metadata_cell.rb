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

      def cache_hash
        hash = []
        hash << "decidim/process_dropdown_metadata"
        hash << id
        hash << current_user.try(:id).to_s
        hash << I18n.locale.to_s

        hash.join(Decidim.cache_key_separator)
      end

      def step_title
        translated_attribute process.active_step&.title
      end

      def display_steps?
        process.steps.present?
      end

      def nav_items_method = :process_nav_items
    end
  end
end
