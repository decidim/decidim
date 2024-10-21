# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      class ConferenceFiltersController < Decidim::Conferences::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasTaxonomyFilters

        def breadcrumb_manage_partial
          "layouts/decidim/admin/manage_conferences"
        end

        def participatory_space_manifest
          :conferences
        end
      end
    end
  end
end
