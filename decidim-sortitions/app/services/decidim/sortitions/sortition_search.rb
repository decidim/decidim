# frozen_string_literal: true

module Decidim
  module Sortitions
    # A service to encapsualte all the logic when searching and filtering
    # sortitions in a participatory process.
    class SortitionSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the proposals from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Sortition.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          .or(
            query.where("additional_info->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          )
          .or(
            query.where("witnesses->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          )
      end

      # Handle the state filter
      def search_state
        case state
        when "active"
          query.active
        when "cancelled"
          query.cancelled
        else # Assume 'all'
          query
        end
      end

      private

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
