# frozen_string_literal: true

# This analyzer checks for too many recursions in GraphQL queries.
# Copyright (c) GitLab B.V.
# License: MIT Expat license
# This content of the class was copied from the GitLab repository
# @see https://gitlab.com/gitlab-org/gitlab/-/blob/f59f7aa0d86f07496e68abf7172edd703669e7bd/lib/gitlab/graphql/query_analyzers/ast/recursion_analyzer.rb
# To which I have modified the result format to be compatible with decidim-api.

module Decidim
  module Api
    class RecursionAnalyzer < GraphQL::Analysis::AST::Analyzer
      IGNORED_FIELDS = %w(node edges nodes ofType).freeze
      RECURSION_THRESHOLD = 2

      def initialize(query)
        super

        @node_visits = {}
        @recurring_fields = {}
      end

      def on_enter_field(node, _parent, visitor)
        return if skip_node?(node, visitor)

        node_name = node.name
        node_visits[node_name] ||= 0
        node_visits[node_name] += 1

        times_encountered = @node_visits[node_name]
        recurring_fields[node_name] = times_encountered if recursion_too_deep?(node_name, times_encountered)
      end

      # Visitors are all defined on the AST::Analyzer base class
      # We override them for custom analyzers.
      def on_leave_field(node, _parent, visitor)
        return if skip_node?(node, visitor)

        node_name = node.name
        node_visits[node_name] ||= 0
        node_visits[node_name] -= 1
      end

      def result
        @recurring_fields = @recurring_fields.select { |k, v| recursion_too_deep?(k, v) }

        Decidim::Api::Errors::RecursionLimitExceededError.new I18n.t("decidim.api.errors.recursion_limit_exceeded_error") if @recurring_fields.any?
      end

      private

      attr_reader :node_visits, :recurring_fields

      def recursion_too_deep?(node_name, times_encountered)
        return false if IGNORED_FIELDS.include?(node_name)

        times_encountered > recursion_threshold
      end

      def skip_node?(node, visitor)
        # We do not want to count skipped fields or fields
        # inside fragment definitions
        return false if visitor.skipping? || visitor.visiting_fragment_definition?

        !node.is_a?(GraphQL::Language::Nodes::Field) || node.selections.empty?
      end

      # Separated into a method to allow overriding or customization of the recursion limit.
      def recursion_threshold
        RECURSION_THRESHOLD
      end
    end
  end
end
