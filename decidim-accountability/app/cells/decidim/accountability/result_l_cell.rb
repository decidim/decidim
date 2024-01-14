# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the List (:l) result card
    # for an instance of a Result
    class ResultLCell < Decidim::CardLCell
      include ApplicationHelper
      include ActiveSupport::NumberHelper

      alias result model

      def component_settings
        controller.try(:component_settings) || result.component.settings
      end

      def render_extra_data?
        true
      end

      private

      def metadata_cell
        "decidim/accountability/result_metadata"
      end
    end
  end
end
