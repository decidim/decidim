# frozen_string_literal: true

module Decidim
  module Initiatives
    # Exposes Initiatives versions so users can see how an Initiative
    # has been updated through time.
    class VersionsController < Decidim::Initiatives::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout
      helper InitiativeHelper

      include NeedsInitiative
      include Decidim::ResourceVersionsConcern

      def versioned_resource
        current_initiative
      end

      private

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= Decidim.find_participatory_space_manifest(:initiatives)
      end
    end
  end
end
