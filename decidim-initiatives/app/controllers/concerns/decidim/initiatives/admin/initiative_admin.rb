# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    module Admin
      # This concern is meant to be included in all controllers that are scoped
      # into an initiative's admin panel. It will override the layout so it shows
      # the sidebar, preload the assembly, etc.
      module InitiativeAdmin
        extend ActiveSupport::Concern
        include InitiativeSlug

        included do
          include NeedsInitiative

          include Decidim::Admin::ParticipatorySpaceAdminContext
          participatory_space_admin_layout

          alias_method :current_participatory_space, :current_initiative
          alias_method :current_participatory_space_manifest, :initiatives_manifest
        end

        private

        def initiatives_manifest
          @initiatives_manifest ||= Decidim.find_participatory_space_manifest(:initiatives)
        end
      end
    end
  end
end
