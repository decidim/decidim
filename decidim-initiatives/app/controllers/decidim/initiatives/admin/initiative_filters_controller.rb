# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      class InitiativeFiltersController < Decidim::Initiatives::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasTaxonomyFilters

        def breadcrumb_manage_partial
          "layouts/decidim/admin/manage_initiatives"
        end

        def participatory_space_manifest
          :initiatives
        end
      end
    end
  end
end
