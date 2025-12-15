# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.permission_not_set")
      class PermissionNotSetError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "NO_PERMISSION_SET" } })
        end
      end
    end
  end
end
