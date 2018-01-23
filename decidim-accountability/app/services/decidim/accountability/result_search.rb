# frozen_string_literal: true

module Decidim
  module Accountability
    # This class handles search and filtering of results. Needs a
    # `current_feature` param with a `Decidim::Feature` in order to
    # find the results.
    class ResultSearch < ResourceSearch
      # Public: Initializes the service.
      #
      # options - A hash of options to modify the search. These options will be
      #          converted to methods by SearchLight so they can be used on filter
      #          methods. (Default {})
      #          * feature - A Decidim::Feature to get the results from.
      #          * organization - A Decidim::Organization object.
      #          * parent_id - The parent ID of the result. The value is forced to false to force
      #                        the filter execution when the value is nil
      def initialize(options = {})
        options[:parent_id] = false if options[:parent_id].nil?

        super(Result.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where(localized_search_text_in(:title), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in(:description), text: "%#{search_text}%"))
      end

      # Handle parent_id filter
      def search_parent_id
        if options[:parent_id] == false
          query.where(parent_id: nil)
        else
          query.where(parent_id: options[:parent_id])
        end
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
        options[:organization].available_locales.map do |l|
          "#{field} ->> '#{l}' ILIKE :text"
        end.join(" OR ")
      end
    end
  end
end
