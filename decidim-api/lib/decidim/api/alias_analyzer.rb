# frozen_string_literal: true

module Decidim
  module Api
    class AliasAnalyzer < GraphQL::Analysis::AST::Analyzer
      def initialize(query)
        super

        @aliases = Set.new
      end

      def on_enter_field(node, _parent, _visitor)
        @aliases.add(node.alias) if node.alias.present?
      end

      def result
        if @aliases.size > Decidim::Api.max_aliases
          Errors::TooManyAliasesError.new(I18n.t("decidim.api.errors.too_many_aliases_error", size: @aliases.size, limit: Decidim::Api.max_aliases))
        end
      end
    end
  end
end
