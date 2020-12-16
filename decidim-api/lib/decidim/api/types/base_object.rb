# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        field_class Types::BaseField
      end
    end
  end
end
