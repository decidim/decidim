# frozen_string_literal: true

module Decidim
  module Core
    class TaxonomyType < Decidim::Api::Types::BaseObject
      description "A taxonomy that can be applied to other resources."

      field :id, GraphQL::Types::ID, null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this taxonomy.", null: false
      field :is_root, Boolean, "Whether this taxonomy is a root taxonomy (root taxonomies have no parents).", null: false
      field :children, [Decidim::Core::TaxonomyType], "The children of this taxonomy.", null: false
      field :parent, Decidim::Core::TaxonomyType, "The parent of this taxonomy.", null: true

      # rubocop:disable Naming/PredicateName
      def is_root
        object.root?
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
