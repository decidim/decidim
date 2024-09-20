# frozen_string_literal: true

module Decidim
  module Accountability
    # This helper include some methods for rendering proposals dynamic maps.
    module MapHelper
      include Decidim::ApplicationHelper
      # Serialize a collection of geocoded proposals to be used by the dynamic map component
      #
      # geocoded_proposals - A collection of geocoded proposals
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

      def result_preview_data_for_map(proposal)
        {
          type: "drag-marker",
          marker: proposal.slice(
            :latitude,
            :longitude,
            :address
          ).merge(
            icon: icon("chat-new-line", width: 40, height: 70, remove_icon_class: true)
          )
        }
      end
    end
  end
end
