# frozen_string_literal: true

module Decidim
  module Pages

    class PageEdge < GraphQL::Types::Relay::BaseEdge
      node_type(PageType)
    end

    class PageConnection < GraphQL::Types::Relay::BaseConnection
      edge_type(PageEdge)
    end

    class PagesType < GraphQL::Schema::Object
      graphql_name "Pages"
      description "A pages component of a participatory space."

      implements Decidim::Core::ComponentInterface

      field :pages, PageConnection, null: false, connection: true
      field(:page, PageType, null: true) do
        argument :id, ID, required: true
      end

      def page(id:)
        pages.find_by(id: id)
      end

      def pages
        PagesTypeHelper.base_scope(object).includes(:component)
      end
      #
      # def resolve_type(obj:, _ctx:)
      #   PagesType
      # end

    end

    module PagesTypeHelper
      def self.base_scope(component)
        Page.where(component: component)
      end
    end
  end
end
