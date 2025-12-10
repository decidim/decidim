# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class UnauthorizedObjectError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "NO_OBJECT_PERMISSION" } })
        end
      end
    end
  end
end
