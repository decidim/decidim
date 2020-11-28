# frozen_string_literal: true

module Decidim
  module Api
    module Types
      module BaseInterface
        include GraphQL::Schema::Interface

        field_class Types::BaseField
      end
    end
  end
end
