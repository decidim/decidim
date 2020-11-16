# frozen_string_literal: true

module Decidim
  module Core

    module ScopableInterface
      include GraphQL::Schema::Interface
      # name "ScopableInterface"
      # description "An interface that can be used in scopable objects."

      field :scope, Decidim::Core::ScopeApiType, null: true, description: "The object's scope"
    end
  end
end
