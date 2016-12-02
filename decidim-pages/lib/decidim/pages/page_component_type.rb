# frozen_string_literal: true
module Decidim
  module Pages
    PageComponentType = GraphQL::ObjectType.define do
      name "PageComponentType"
      interfaces [Decidim::Api::ComponentInterfaceType]
    end
  end
end
