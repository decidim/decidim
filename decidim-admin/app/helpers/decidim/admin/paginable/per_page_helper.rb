# frozen_string_literal: true

module Decidim
  module Admin
    module Paginable
      # This module includes helpers the :per_page cell's option
      module PerPageHelper
        def per_page_options
          OpenStruct.new(
            per_page:,
            per_page_range: Decidim::Admin.per_page_range
          )
        end

        # Renders the pagination dropdown menu in the admin panel.
        def admin_filters_pagination
          cell("decidim/admin/results_per_page", per_page_options)
        end
      end
    end
  end
end
