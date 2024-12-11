# frozen_string_literal: true

module Decidim
  module Accountability
    # This helper include some methods for rendering results dynamic maps.
    module MapHelper
      include Decidim::ApplicationHelper
      # Serialize a collection of geocoded results to be used by the dynamic map component
      #
      # geocoded_results - A collection of geocoded results
      def results_data_for_map(geocoded_results)
        geocoded_results.map do |result|
          result_data_for_map(result)
        end
      end

      def result_data_for_map(result)
        result
          .slice(:latitude, :longitude, :address)
          .merge(
            title: decidim_html_escape(present(result).title),
            link: result_path(result.id),
            items: cell("decidim/accountability/result_metadata", result).send(:result_items_for_map).to_json
          )
      end
    end
  end
end
