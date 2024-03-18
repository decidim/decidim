# frozen_string_literal: true

module Decidim
  module Admin
    class ResultsPerPageCell < Decidim::ViewModel
      property :per_page, :per_page_range
      def path_for_num_per_page(num_per_page = per_page_range.first)
        controller.url_for(params.to_unsafe_h.merge(per_page: num_per_page))
      end
    end
  end
end
