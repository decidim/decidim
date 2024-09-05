# frozen_string_literal: true

module Decidim
  module Core
    class TaxonomyType < Decidim::Api::Types::BaseObject
      description "A taxonomy that can be applied to other resources."

      field :id, GraphQL::Types::ID, null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this taxonomy.", null: false
    end
  end
end
