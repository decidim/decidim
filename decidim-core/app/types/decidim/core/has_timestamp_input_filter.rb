# frozen_string_literal: true

module Decidim
  module Core
    module HasTimestampInputFilter
      def self.included(child_class)
        child_class.argument :created_before,
                             type: String,
                             description: "List result created **before** (and **excluding**) this date. Expected format `YYYY-MM-DD`",
                             required: false,
                             prepare: ->(date, _ctx) do
                               proc do |model_class|
                                 model_class.arel_table[:created_at].lt(date_to_iso8601(date, :createdBefore))
                               end
                             end
        child_class.argument :created_since,
                             type: String,
                             description: "List result created after (and **including**) this date. Expected format `YYYY-MM-DD`",
                             required: false,
                             prepare: ->(date, _ctx) do
                               proc do |model_class|
                                 model_class.arel_table[:created_at].gteq(date_to_iso8601(date, :createdBefore))
                               end
                             end
        child_class.argument :updated_before,
                             type: String,
                             description: "List result updated **before** (and **excluding**) this date. Expected format `YYYY-MM-DD`",
                             required: false,
                             prepare: ->(date, _ctx) do
                               proc do |model_class|
                                 model_class.arel_table[:updated_at].lt(date_to_iso8601(date, :updatedBefore))
                               end
                             end
        child_class.argument :updated_since,
                             type: String,
                             description: "List result updated after (and **including**) this date. Expected format `YYYY-MM-DD`",
                             required: false,
                             prepare: ->(date, _ctx) do
                               proc do |model_class|
                                 model_class.arel_table[:updated_at].gteq(date_to_iso8601(date, :updatedBefore))
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
