# frozen_string_literal: true

module Decidim
  module Meetings
    module ContentBlocks
      class HighlightedMeetingsCell < Decidim::ContentBlocks::HighlightedElementsCell
        def base_relation
          Decidim::Meetings::Meeting.where(component: published_components)
        end

        def elements
          @elements ||= base_relation.order(start_time: :asc).limit(limit)
        end

        def geolocation_enabled?
          Decidim::Map.available?(:geocoding)
        end

        private

        def limit
          geolocation_enabled? ? 4 : 8
        end
      end
    end
  end
end
