# frozen_string_literal: true

module Decidim
  module Conferences
    # This query filters conferences so only promoted ones are returned.
    class PromotedConferences < Rectify::Query
      def query
        Decidim::Conference.promoted
      end
    end
  end
end
