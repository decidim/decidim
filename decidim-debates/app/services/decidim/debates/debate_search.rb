# frozen_string_literal: true

module Decidim
  module Debates
    # This class handles search and filtering of debates. Needs a
    # `current_feature` param with a `Decidim::Feature` in order to
    # find the debates.
    class DebateSearch < ResourceSearch
      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the debates from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Debate.not_hidden, options)
      end

      # Handle the search_text filter. We have to cast the JSONB columns
      # into a `text` type so that we can search.
      def search_search_text
        query
          .where("title::text ILIKE ?", "%#{search_text}%")
          .or(query.where("description::text ILIKE ?", "%#{search_text}%"))
      end

      # Handle the origin filter
      # The 'official' proposals doesn't have an author id
      def search_origin
        if origin == "official"
          query.where(decidim_author_id: nil)
        elsif origin == "citizens"
          query.where.not(decidim_author_id: nil)
        else # Assume 'all'
          query
        end
      end

      # Handle the order_start_time filter
      def search_order_start_time
        query.order(start_time: order_start_time)
      end

      # Handle the scope_id filter
      def search_scope_id
        query.where(decidim_scope_id: scope_id)
      end
    end
  end
end
