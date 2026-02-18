# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.not_found")
      class NotFoundError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "NOT_FOUND_ERROR" } })
        end
      end
    end
  end
end
