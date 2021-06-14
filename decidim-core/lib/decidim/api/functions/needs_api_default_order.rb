# frozen_string_literal: true

module Decidim
  module Core
    module NeedsApiDefaultOrder
      private

      # Add default order to the query in order to avoid random PostgreSQL
      # ordering between the queries for different pages of results. If some of
      # the queried records are updated or new records are added between the
      # API calls to different pages of records, PostgreSQL can randomly change
      # the order causing duplicates to appear or some records to disappear from
      # the results unless the order of the records is explicitly defined.
      #
      # Note that this needs to be called as the last method before returning
      # the query so that it won't affect the desired ordering specified in the
      # GraphQ query. In that case, ordering by ID will be the secondary order
      # of the records.
      def add_default_order
        @query = @query.order(:id)
      end
    end
  end
end
