# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        field_class Types::BaseField

        def initialize(object, context)
          Rails.logger.info("#{self} was initialized")
          super
        end
      end
    end
  end
end
