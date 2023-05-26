# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include AssembliesHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      def decidim_assemblies
        Decidim::Assemblies::Engine.routes.url_helpers
      end

      private

      def nav_items_method = :assembly_nav_items
    end
  end
end
