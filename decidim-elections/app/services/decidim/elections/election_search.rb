# frozen_string_literal: true

module Decidim
  module Elections
    # This class handles search and filtering of elections.
    class ElectionSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the election from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Election.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("decidim_elections_elections.title::text ILIKE ?", "%#{search_text}%")
          .or(query.where("decidim_elections_elections.description::text ILIKE ?", "%#{search_text}%"))
      end

      # Handle the state filter
      def search_state
        active = state.member?("active") ? query.active : nil
        upcoming = state.member?("upcoming") ? query.upcoming : nil
        finished = state.member?("finished") ? query.finished : nil

        query
          .where(id: upcoming)
          .or(query.where(id: active))
          .or(query.where(id: finished))
      end
    end
  end
end
