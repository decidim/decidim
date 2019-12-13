# frozen_string_literal: true

module Decidim
  module Core
    module HasPublishableInputFilter
      def self.included(child_class)
        child_class.argument :publishedBefore, Decidim::Core::DateType, "List result published before (non including) this date", required: false, prepare: ->(date, ctx) {
          raise GraphQL::ExecutionError, "Invalid date format for published_at" unless Date.try(:iso8601, date)
          {attr: :published_at, func: :lt, value: date}
        }
        child_class.argument :publishedSince, Decidim::Core::DateType, "List result published after (and including) this date", required: false, prepare: ->(date, ctx) {
          {attr: :published_at, func: :gteq, value: date}
        }
      end
    end
  end
end
