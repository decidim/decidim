# frozen_string_literal: true

module Decidim
  module Conferences
    # This query orders conferences by importance, prioritizing promoted
    # conferences.
    class PrioritizedConferences < Decidim::Query
      def query
        Decidim::Conference.order(promoted: :desc)
      end
    end
  end
end
