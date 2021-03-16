# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a categorizable object.
    CategorizableInterface = GraphQL::InterfaceType.define do
      name "CategorizableInterface"
      description "An interface that can be used in categorizable objects."

      field :category, Decidim::Core::CategoryType, "The object's category"
    end
  end
end
