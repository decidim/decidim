# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class MutationNotAuthorizedError < GraphQL::ExecutionError
        def to_h
          super.merge({ "extensions" => { "code" => "MUTATION_NOT_AUTHORIZED" } })
        end
      end
    end
  end
end
