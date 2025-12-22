# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      # i18n-tasks-use t("decidim.api.errors.unauthorized_mutation")
      class MutationNotAuthorizedError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "MUTATION_NOT_AUTHORIZED_ERROR" } })
        end
      end
    end
  end
end
