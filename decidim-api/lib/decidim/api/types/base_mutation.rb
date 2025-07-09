# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseMutation < GraphQL::Schema::RelayClassicMutation
        include Decidim::Api::GraphqlPermissions

        object_class BaseObject
        field_class Types::BaseField
        input_object_class BaseInputObject

        required_scopes "api:read", "api:write"

        private

        def handle_form_submission(&block)
          result = block.call

          if result[:ok]
            # The result should be reloaded to reflect the associations
            return result[:ok].reload
          elsif result[:invalid]
            return GraphQL::ExecutionError.new(result[:invalid].errors.full_messages.join(", "))
          end
        end
      end
    end
  end
end
