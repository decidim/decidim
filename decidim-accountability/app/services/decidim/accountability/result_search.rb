# frozen_string_literal: true

module Decidim
  module Accountability
    # This class handles search and filtering of results. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the results.
    class ResultSearch < ResourceSearch
      text_search_fields :title, :description

      # Public: Initializes the service.
      #
      # options - A hash of options to modify the search. These options will be
      #          converted to methods by SearchLight so they can be used on filter
      #          methods. (Default {})
      #          * component - A Decidim::Component to get the results from.
      #          * organization - A Decidim::Organization object.
      #          * parent_id - The parent ID of the result. The value is forced to false to force
      #                        the filter execution when the value is nil
      #          * deep_search - Whether to perform the search on all children levels or just the
      #                          first one. True by default.
      def initialize(options = {})
        options = options.dup
        options[:deep_search] = true if options[:deep_search].nil?
        options[:parent_id] = "root" if options[:parent_id].nil?
        super(Result.all, options)
      end

      # Handle parent_id filter
      def search_parent_id
        parent_id = options[:parent_id]
        parent_id = nil if parent_id == "root"

        if options[:deep_search]
          query.where(parent_id: [parent_id] + children_ids(parent_id))
        else
          query.where(parent_id: parent_id)
        end
      end

      private

      def children_ids(parent_id)
        Result.where(parent_id: parent_id).pluck(:id)
      end
    end
  end
end
