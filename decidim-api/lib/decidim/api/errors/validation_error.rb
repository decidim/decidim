# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class ValidationError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "VALIDATION_ERROR" } })
        end
      end
    end
  end
end
