# frozen_string_literal: true

module Decidim
  module Core
    class TaxonomyType < Decidim::Api::Types::BaseObject
      description "A taxonomy that can be applied to other resources."

      field :children, [Decidim::Core::TaxonomyType], "The children of this taxonomy.", null: false
      field :id, GraphQL::Types::ID, null: false
      field :is_root, Boolean, "Whether this taxonomy is a root taxonomy (root taxonomies have no parents).", null: false, method: :root?
      field :name, Decidim::Core::TranslatedFieldType, "The name of this taxonomy.", null: false
      field :parent, Decidim::Core::TaxonomyType, "The parent of this taxonomy.", null: true
    end
  end
end
