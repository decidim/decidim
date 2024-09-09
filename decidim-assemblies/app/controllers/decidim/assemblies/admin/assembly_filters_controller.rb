# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller used to manage participatory process types for the current
      # organization
      class AssemblyFiltersController < Decidim::Assemblies::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasTaxonomyFilters

        def breadcrumb_manage_partial
          "layouts/decidim/admin/manage_assemblies"
        end

        def participatory_space_manifest
          :assemblies
        end
      end
    end
  end
end
