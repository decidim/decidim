# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Assemblies
    module Admin
      module Concerns
        # This concern is meant to be included in all controllers that are scoped
        # into an assembly's admin panel. It will override the layout so it shows
        # the sidebar, preload the assembly, etc.
        module AssemblyAdmin
          extend ActiveSupport::Concern

          included do
            include NeedsAssembly

            layout "decidim/admin/assembly"

            alias_method :current_participatory_space, :current_assembly
          end
        end
      end
    end
  end
end
