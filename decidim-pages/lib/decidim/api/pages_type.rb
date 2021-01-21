# frozen_string_literal: true

module Decidim
  module Pages
    class PagesType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Pages"
      description "A pages component of a participatory space."

      field :pages, PageType.connection_type, null: true, connection: true

      def pages
        PagesTypeHelper.base_scope(object).includes(:component)
      end

      field :page, PageType, null: true do
        argument :id, ID, required: true
      end

      def page(**args)
        PagesTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module PagesTypeHelper
      def self.base_scope(component)
        Page.where(component: component)
      end
    end
  end
end
