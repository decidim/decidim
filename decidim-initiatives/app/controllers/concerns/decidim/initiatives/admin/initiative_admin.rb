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

        included do
          include Decidim::Admin::ParticipatorySpaceAdminContext
          include NeedsInitiative

          participatory_space_admin_layout
        end
      end
    end
  end
end
