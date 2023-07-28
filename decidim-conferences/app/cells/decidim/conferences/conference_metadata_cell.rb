# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Conferences
    class ConferenceMetadataCell < Decidim::CardMetadataCell
      def items
        [dates_item].compact
      end

      def start_date
        model.start_date.to_time
      end

      def end_date
        model.end_date.to_time
      end
    end
  end
end
