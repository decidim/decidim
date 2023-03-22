# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include Decidim::TwitterSearchHelper
      include AssembliesHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      alias assembly model
      alias current_participatory_space model

      def decidim_assemblies
        Decidim::Assemblies::Engine.routes.url_helpers
      end

      private

      def hashtag
        @hashtag ||= decidim_html_escape(assembly.hashtag) if assembly.hashtag.present?
      end

      def nav_items
        return super if (nav_items = try(:assembly_nav_items, assembly)).blank?

        nav_items
      end
    end
  end
end
