# frozen_string_literal: true

module Decidim
  module Debates
    # This class handles search and filtering of debates. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the debates.
    class DebateSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the debates from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Debate.not_hidden, options)
      end

      # Handle the search_text filter. We have to cast the JSONB columns
      # into a `text` type so that we can search.
      def search_search_text
        query
          .where("decidim_debates_debates.title::text ILIKE ?", "%#{search_text}%")
          .or(query.where("decidim_debates_debates.description::text ILIKE ?", "%#{search_text}%"))
      end

      # Handle the origin filter
      def search_origin
        if origin == "official"
          query.where(author: component.organization)
        elsif origin == "citizens"
          query.where.not(decidim_author_type: "Decidim::Organization")
        else # Assume 'all'
          query
        end
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
    end
  end
end
