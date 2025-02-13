# frozen_string_literal: true

module Decidim
  module Proposals
    # This helper include some methods for rendering proposals dynamic maps.
    module MapHelper
      include Decidim::ApplicationHelper

      def proposal_preview_data_for_map(proposal)
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

      def has_position?(proposal)
        return if proposal.address.blank?

        proposal.latitude.present? && proposal.longitude.present?
      end
    end
  end
end
