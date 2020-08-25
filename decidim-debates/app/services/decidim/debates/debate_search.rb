# frozen_string_literal: true

module Decidim
  module Debates
    # This class handles search and filtering of debates. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the debates.
    class DebateSearch < ResourceSearch
      attr_reader :current_user

      # Public: Initializes the service.
      # component     - A Decidim::Component to get the debates from.
      # page        - The page number to paginate the results.
      # per_page    - The number of debates to return per page.
      def initialize(options = {})
        super(Debate.not_hidden, options)

        @current_user = options[:current_user]
      end

      # Handle the search_text filter. We have to cast the JSONB columns
      # into a `text` type so that we can search.
      def search_search_text
        query
          .where(localized_search_text_in("decidim_debates_debates.title"), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in("decidim_debates_debates.description"), text: "%#{search_text}%"))
      end

      # Handle the origin filter
      def search_origin
        official = origin.member?("official") ? query.official_origin : nil
        citizens = origin.member?("citizens") ? query.citizens_origin : nil
        user_group = origin.member?("user_group") ? query.user_group_origin : nil

        query
          .where(id: official)
          .or(query.where(id: citizens))
          .or(query.where(id: user_group))
      end

      def search_order_start_time
        if order_start_time == "asc"
          query.order("start_time ASC")
        elsif order_start_time == "desc"
          query.order("start_time DESC")
        else
          query.order("start_time ASC")
        end
      end

      def search_scope_id
        super
      end

      # Handle the activity filter
      def search_activity
        case activity
        when "commented"
          query.commented_by(current_user)
        when "my_debates"
          query.authored_by(current_user)
        else # Assume 'all'
          query
        end
      end

      # Handle the state filter
      def search_state
        open = state.member?("open") ? query.open : nil
        closed = state.member?("closed") ? query.closed : nil

        query
          .where(id: open)
          .or(query.where(id: closed))
      end

      # We overwrite the `results` method to ensure we only return unique
      # results. We can't use `#uniq` because it returns an Array and we're
      # adding scopes in the controller, and `#distinct` doesn't work here
      # because in the later scopes we're ordering by `RANDOM()` in a DB level,
      # and `SELECT DISTINCT` doesn't work with `RANDOM()` sorting, so we need
      # to perform two queries.
      #
      # The correct behaviour is backed by tests.
      def results
        Debate.where(id: super.pluck(:id))
      end
    end
  end
end
