# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.introspection_disabled")
      class IntrospectionDisabledError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "INTROSPECTION_DISABLED_ERROR" } })
        end
      end
    end
  end
end
