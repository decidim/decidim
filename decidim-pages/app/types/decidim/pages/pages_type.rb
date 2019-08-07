# frozen_string_literal: true

module Decidim
  module Pages
    PagesType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Pages"
      description "A pages component of a participatory space."

      connection :pages, PageType.connection_type do
        resolve ->(component, _args, _ctx) {
                  PagesTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:page, PageType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          PagesTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module PagesTypeHelper
      def self.base_scope(component)
        Page.where(component: component)
      end
    end
  end
end
