# frozen_string_literal: true

module Decidim
  module Core
    class ComponentType < GraphQL::Schema::Object
      graphql_name "Component"
      implements ComponentInterface

      description "A base component with no particular specificities."
    end
  end
end
