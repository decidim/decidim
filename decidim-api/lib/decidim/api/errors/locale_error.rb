# frozen_string_literal: true


module Decidim
  module Api
    module Errors
      class LocaleError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "LOCALE_ERROR" } })
        end
      end
    end
  end
end
