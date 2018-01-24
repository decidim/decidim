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
        return query if options[:parent_id].blank?
        query.where(parent_id: children_ids(options[:parent_id]))
      end

      private

      def children_ids(parent_id)
        [parent_id] + Result.where(parent_id: parent_id).pluck(:id).flat_map do |child_id|
          children_ids(child_id)
        end
      end

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
