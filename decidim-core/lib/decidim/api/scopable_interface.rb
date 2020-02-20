# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a scopable object.
    ScopableInterface = GraphQL::InterfaceType.define do
      name "ScopableInterface"
      description "An interface that can be used in scopable objects."

      field :scope, Decidim::Core::ScopeApiType, "The object's scope"
    end
  end
end
