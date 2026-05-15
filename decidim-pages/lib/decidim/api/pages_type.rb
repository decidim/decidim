# frozen_string_literal: true

module Decidim
  module Pages
    class PagesType < Decidim::Core::ComponentType
      graphql_name "Pages"
      description "A pages component of a participatory space."

      field :page, Decidim::Pages::PageType, "A single Page object", null: true do
        argument :id, GraphQL::Types::ID, "The id of the Page requested", required: true
      end
      field :pages, Decidim::Pages::PageType.connection_type, "A collection of Pages", null: true, connection: true

      def pages
        Page.where(component: object).includes(:component)
      end

      def page(id:)
        Decidim::Core::ComponentFinderBase.new(model_class: Page).call(object, { id: }, context)
      end
    end
  end
end
