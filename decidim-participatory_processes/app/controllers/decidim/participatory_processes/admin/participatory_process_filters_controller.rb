# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller used to manage participatory process types for the current
      # organization
      class ParticipatoryProcessFiltersController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasTaxonomyFilters

        def participatory_space_manifest
          :participatory_processes
        end

        def breadcrumb_manage_partial
          "layouts/decidim/admin/manage_processes"
        end
      end
    end
  end
end
