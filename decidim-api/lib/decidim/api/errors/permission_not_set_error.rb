# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.permission_not_set")
      class PermissionNotSetError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "PERMISSION_NOT_SET_ERROR" } })
        end
      end
    end
  end
end
