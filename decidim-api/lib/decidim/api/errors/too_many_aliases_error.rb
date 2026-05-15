# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.too_many_aliases_error")

      class TooManyAliasesError < GraphQL::AnalysisError
        def to_h
          super.merge({ "extensions" => { "code" => "TOO_MANY_ALIASES_ERROR" } })
        end
      end
    end
  end
end
