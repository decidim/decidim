# frozen_string_literal: true
module Decidim
  module Api
    ComponentType = GraphQL::ObjectType.define do
      name "ComponentType"
      interfaces [Decidim::Api::ComponentInterfaceType]
    end
  end
end
