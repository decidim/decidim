# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object that have a reference field.
    module ReferableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in display reference methods"

      field :reference, GraphQL::Types::String, "The reference for this record", null: true
    end
  end
end
