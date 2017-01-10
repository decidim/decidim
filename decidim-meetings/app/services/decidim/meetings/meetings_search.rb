# frozen_string_literal: true
module Decidim
  module Meetings
    # This class handles search and filtering of meetings. Needs a
    # `current_feature` param with a `Decidim::Feature` in order to
    # find the meetings.
    class MeetingsSearch < Searchlight::Search
      def base_query
        raise "Missing feature" unless current_feature

        Meeting
          .page(options[:page] || 1)
          .per(options[:per_page] || 12)
          .where(feature: current_feature)
      end

      def search_order_start_time
        query.order(start_time: order_start_time)
      end

      def search_scope_id
        query.where(decidim_scope_id: scope_id)
      end

      def search_category_id
        query.where(decidim_category_id: category_ids)
      end

      private

      def category_ids
        current_feature
          .categories
          .where(id: category_id)
          .or(current_feature.categories.where(parent_id: category_id))
          .pluck(:id)
      end

      def current_feature
        options[:feature]
      end
    end
  end
end
