# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.invalid_locale")
      class LocaleError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "LOCALE_ERROR" } })
        end
      end
    end
  end
end
