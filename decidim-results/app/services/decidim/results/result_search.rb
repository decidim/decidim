# frozen_string_literal: true
module Decidim
  module Results
    # This class handles search and filtering of results. Needs a
    # `current_feature` param with a `Decidim::Feature` in order to
    # find the results.
    class ResultSearch < ResourceSearch
      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the results from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Result.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where(localized_search_text_in(:title), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in(:description), text: "%#{search_text}%"))
          .or(query.where(localized_search_text_in(:short_description), text: "%#{search_text}%"))
      end

      # Handle the scope_id filter
      def search_scope_id
        query.where(decidim_scope_id: scope_id)
      end

      private

      # Internal: builds the needed query to search for a text in the organization's
      # available locales. Note that it is intended to be used as follows:
      #
      # Example:
      #   Resource.where(localized_search_text_for(:title, text: "my_query"))
      #
      # The Hash with the `:text` key is required or it won't work.
      def localized_search_text_in(field)
        options[:organization].available_locales.map{|l| "#{field} ->> '#{l}' ILIKE :text"}.join(" OR ")
      end
    end
  end
end
