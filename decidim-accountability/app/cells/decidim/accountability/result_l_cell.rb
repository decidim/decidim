# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the List (:l) result card
    # for an instance of a Result
    class ResultLCell < Decidim::CardLCell
      include ApplicationHelper
      include ActiveSupport::NumberHelper

      delegate :component_settings, to: :controller

      alias result model

      private

      def metadata_cell
        "decidim/accountability/result_metadata"
      end
    end
  end
end
