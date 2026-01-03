# frozen_string_literal: true

module Decidim
  module Api
    class AliasAnalyzer < GraphQL::Analysis::AST::Analyzer
      def initialize(query)
        super

        @aliases = {}
      end

      def on_enter_field(node, _parent, _visitor)
        if node.alias.present?
          alias_name = node.alias
          @aliases[alias_name] ||= 1
        end
      end

      def result
        GraphQL::AnalysisError.new("Too many aliases used: #{@aliases.keys.join(",")}") if @aliases.size > Decidim::Api.max_aliases
      end
    end
  end
end
