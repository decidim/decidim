# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class NotFoundError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "NOT_FOUND" } })
        end
      end
    end
  end
end
