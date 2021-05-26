# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a scopable object.
    module ScopableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in scopable objects."

      field :scope, Decidim::Core::ScopeApiType, "The object's scope", null: true
    end
  end
end
