# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessDropdownMetadataCell < Decidim::ViewModel
      include Decidim::SanitizeHelper
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

      def title
        decidim_html_escape(translated_attribute(process.title))
      end

      def step_title
        translated_attribute process.active_step.title
      end

      def hashtag
        @hashtag ||= decidim_html_escape(process.hashtag) if process.hashtag.present?
      end
    end
  end
end
