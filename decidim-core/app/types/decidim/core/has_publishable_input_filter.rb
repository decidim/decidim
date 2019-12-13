# frozen_string_literal: true

module Decidim
  module Core
    module HasPublishableInputFilter
      def self.included(child_class)
        child_class.argument :publishedBefore,
                             type: String,
                             description: "List result published before (non including) this date",
                             required: false,
                             prepare: ->(date, _ctx) do
                               { attr: :published_at, func: :lt, value: date_to_iso8601(date, :publishedBefore) }
                             end
        child_class.argument :publishedSince,
                             type: String,
                             description: "List result published after (and including) this date",
                             required: false,
                             prepare: ->(date, _ctx) do
                               { attr: :published_at, func: :gteq, value: date_to_iso8601(date, :publishedSince) }
                             end
      end

      def self.date_to_iso8601(date, key)
        Date.iso8601(date)
      rescue StandardError
        raise GraphQL::ExecutionError, "Invalid date format for #{key}"
      end
    end
  end
end
