# frozen_string_literal: true

module Decidim
  module Pages
    class PagesType < Decidim::Core::ComponentType
      graphql_name "Pages"
      description "A pages component of a participatory space."

      field :page, Decidim::Pages::PageType, null: true do
        argument :id, GraphQL::Types::ID, required: true
      end
      field :pages, Decidim::Pages::PageType.connection_type, null: true, connection: true

      def pages
        Page.where(component: object).includes(:component)
      end

      def page(**args)
        Page.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
