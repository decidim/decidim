# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.locale_argument_error")
      class InvalidLocaleError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "INVALID_LOCALE_ERROR" } })
        end
      end
    end
  end
end
