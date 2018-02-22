# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a ParticipatoryProcess.
    ComponentType = GraphQL::ObjectType.define do
      interfaces [ComponentInterface]

      name "Component"
      description "A base component with no particular specificities."
    end
  end
end
