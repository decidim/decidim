# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class CollaborativeTextsType < Decidim::Api::Types::BaseObject
      graphql_name "CollaborativeTexts"
      description "A collaborative_texts component of a participatory space."

      def collaborative_texts
        Document.published.visible.where(component: object).includes(:component)
      end

      def meeting(**args)
        Document.published.visible.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
