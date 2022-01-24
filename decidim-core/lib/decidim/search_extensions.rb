# frozen_string_literal: true

module Decidim
  # A concern that adds extra search helpers for the models for Ransack
  # searches.
  module SearchExtensions
    extend ActiveSupport::Concern

    class_methods do
      def ransacker_i18n(field_name, attr_name = nil)
        ransacker field_name do |parent|
          Arel::Nodes::InfixOperation.new("->>", parent.table[attr_name || field_name], Arel::Nodes.build_quoted(I18n.locale.to_s))
        end
      end

      def ransacker_i18n_multi(field_name, attrs)
        raise "The second argument needs to be an array" unless attrs.is_a?(Array)
        raise "You need to define at least one field in the second argument" if attrs.count < 1
        return ransacker_i18n(field_name, attrs.first) if attrs.count < 2

        # Build a grouped OR query with all the fields.
        ransacker field_name do |parent|
          node = nil
          attrs.each do |attr_name|
            target = Arel::Nodes::InfixOperation.new("->>", parent.table[attr_name], Arel::Nodes.build_quoted(I18n.locale.to_s))
            casted = Arel::Nodes::NamedFunction.new("CAST", [target.as("TEXT")])

            if node.nil?
              node = casted
            else
              operation = Arel::Nodes::InfixOperation.new("||", casted, Arel::Nodes.build_quoted(" "))
              node = Arel::Nodes::InfixOperation.new("||", node, operation)
            end
          end

          Arel::Nodes::Grouping.new(node)
        end
      end

      def ransacker_text_multi(field_name, attrs)
        raise "The second argument needs to be an array" unless attrs.is_a?(Array)
        raise "You need to define at least two fields in the second argument" if attrs.count < 1

        # Build a grouped OR query with all the fields.
        ransacker field_name do |parent|
          node = nil
          attrs.each do |attr_name|
            target = parent.table[attr_name]

            if node.nil?
              node = target
            else
              operation = Arel::Nodes::InfixOperation.new("||", target, Arel::Nodes.build_quoted(" "))
              node = Arel::Nodes::InfixOperation.new("||", node, operation)
            end
          end

          Arel::Nodes::Grouping.new(node)
        end
      end

      def scope_search_multi(scope_key, possible_scopes)
        scope scope_key, lambda { |*value_keys|
          search_values = value_keys.compact.reject(&:blank?)

          conditions = possible_scopes.map do |scope|
            search_values.member?(scope.to_s) ? try(scope) : nil
          end.compact
          return self unless conditions.any?

          scoped_query = where(id: conditions.shift)
          conditions.each do |condition|
            scoped_query = scoped_query.or(where(id: condition))
          end

          scoped_query
        }
      end
    end
  end
end
