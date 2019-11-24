# frozen_string_literal: true

module Decidim
  module Admin
    module Paginable
      # This module includes helpers the :per_page cell's option
      module PerPageHelper
        def results_filter_options
          OpenStruct.new(
            per_page_options: per_page_options
          )
        end

        def per_page_options
          OpenStruct.new(
            per_page: per_page,
            per_page_range: Decidim::Admin.per_page_range
          )
        end
      end
    end
  end
end
