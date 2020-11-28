# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseInputObject < GraphQL::Schema::InputObject
        argument_class Types::BaseArgument
      end
    end
  end
end
