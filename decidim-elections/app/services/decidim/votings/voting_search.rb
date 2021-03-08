# frozen_string_literal: true

module Decidim
  module Votings
    # Service that encapsulates all logic related to filtering votings.
    class VotingSearch < Searchlight::Search
      # Public: Initializes the service.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(options)
      end

      def base_query
        Decidim::Votings::Voting.where(organization: options[:organization]).published
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          .or(
            query.where("description->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          )
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

      private

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
