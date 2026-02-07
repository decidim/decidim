# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.unauthorized_field")
      class UnauthorizedFieldError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "UNAUTHORIZED_FIELD_ERROR" } })
        end
      end
    end
  end
end
