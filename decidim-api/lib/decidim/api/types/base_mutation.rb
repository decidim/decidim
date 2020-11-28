# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseMutation < GraphQL::Schema::RelayClassicMutation
        object_class BaseObject
        field_class BaseField
        input_object_class BaseInputObject
      end
    end
  end
end
