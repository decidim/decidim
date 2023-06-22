# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Conferences
    class ConferenceMetadataCell < Decidim::CardMetadataCell
      delegate :start_date, :end_date, to: :model

      def items
        [dates_item].compact
      end
    end
  end
end
