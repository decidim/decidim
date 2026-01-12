# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class RecursionLimitExceededError < GraphQL::AnalysisError
        def to_h
          super.merge({ "extensions" => { "code" => "RECURSION_LIMIT_EXCEEDED_ERROR" } })
        end
      end
    end
  end
end
