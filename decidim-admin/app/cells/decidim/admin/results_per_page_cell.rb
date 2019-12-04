# frozen_string_literal: true

module Decidim
  module Admin
    class ResultsPerPageCell < Decidim::ViewModel
      property :per_page, :per_page_range, :with_label

      def path_for_num_per_page(num_per_page = per_page_range.first)
        %(#{request.path}?per_page=#{num_per_page})
      end
    end
  end
end
