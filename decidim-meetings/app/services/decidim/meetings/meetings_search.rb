# frozen_string_literal: true
module Decidim
  module Meetings
    # This class handles search and filtering of meetings. Needs a
    # `current_feature` param with a `Decidim::Feature` in order to
    # find the meetings.
    class MeetingsSearch < Searchlight::Search
      def base_query
        raise "Missing feature" unless options[:current_feature]
        Meeting.where(feature: options[:current_feature])
      end

      def search_order_start_time
        query.order(start_time: order_start_time)
      end

      def search_scope_id
        query.where(decidim_scope_id: scope_id)
      end
    end
  end
end
