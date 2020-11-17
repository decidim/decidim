# frozen_string_literal: true

module Decidim
  module Pages
    class PagesType < GraphQL::Schema::Object
      graphql_name "Pages"
      description "A pages component of a participatory space."

      implements Decidim::Core::ComponentInterface

      field :pages, PageType.connection_type, null: false
      field(:page, PageType, null: true) do
        argument :id, ID, required: true
      end

      def page(id:)
        pages.find_by(id: id)
      end

      def pages
        PagesTypeHelper.base_scope(object).includes(:component)
      end
    end

    module PagesTypeHelper
      def self.base_scope(component)
        Page.where(component: component)
      end
    end
  end
end
