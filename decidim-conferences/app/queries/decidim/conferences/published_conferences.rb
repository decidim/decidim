# frozen_string_literal: true

module Decidim
  module Conferences
    # This query filters published conferences only.
    class PublishedConferences < Decidim::Query
      def query
        Decidim::Conference.published.not_trashed
      end
    end
  end
end
