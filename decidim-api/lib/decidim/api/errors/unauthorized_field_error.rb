# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class UnauthorizedFieldError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "NO_FIELD_PERMISSION" } })
        end
      end
    end
  end
end
