# frozen_string_literal: true
module Decidim
  module Results
    # This class handles search and filtering of meetings. Needs a
    # `current_feature` param with a `Decidim::Feature` in order to
    # find the meetings.
    class ResultSearch < ResourceSearch
      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the meetings from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Result.all, options)
      end

      # Handle the scope_id filter
      def search_scope_id
        query.where(decidim_scope_id: scope_id)
      end
    end
  end
end
