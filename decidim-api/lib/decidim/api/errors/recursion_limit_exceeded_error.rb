# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.recursion_limit_exceeded_error")
      class RecursionLimitExceededError < GraphQL::AnalysisError
        def to_h
          super.merge({ "extensions" => { "code" => "RECURSION_LIMIT_EXCEEDED_ERROR" } })
        end
      end
    end
  end
end
