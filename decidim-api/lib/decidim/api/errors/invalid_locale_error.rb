# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class InvalidLocaleError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "INVALID_LOCALE" } })
        end
      end
    end
  end
end
