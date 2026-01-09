# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.unauthorized_object")
      class UnauthorizedObjectError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "UNAUTHORIZED_OBJECT_ERROR" } })
        end
      end
    end
  end
end
