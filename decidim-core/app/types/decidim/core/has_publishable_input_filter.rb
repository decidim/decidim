# frozen_string_literal: true

module Decidim
  module Core
    module HasPublishableInputFilter
      def self.included(child_class)
        child_class.argument :published_before,
                             type: String,
                             description: "List result published **before** (and **excluding**) this date. Expected format `YYYY-MM-DD`",
                             required: false,
                             prepare: ->(date, _ctx) do
                               proc do |model_class|
                                 model_class.arel_table[:published_at].lt(date_to_iso8601(date, :publishedBefore))
                               end
                             end
        child_class.argument :published_since,
                             type: String,
                             description: "List result published after (and **including**) this date. Expected format `YYYY-MM-DD`",
                             required: false,
                             prepare: ->(date, _ctx) do
                               proc do |model_class|
                                 model_class.arel_table[:published_at].gteq(date_to_iso8601(date, :publishedBefore))
                               end
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
