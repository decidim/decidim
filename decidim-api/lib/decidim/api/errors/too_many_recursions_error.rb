# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class TooManyRecursionsError < GraphQL::AnalysisError
        def to_h
          super.merge({ "extensions" => { "code" => "TOO_MANY_RECURSIONS_ERROR" } })
        end
      end
    end
  end
end
