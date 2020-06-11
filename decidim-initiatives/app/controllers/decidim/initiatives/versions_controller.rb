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
    end
  end
end
