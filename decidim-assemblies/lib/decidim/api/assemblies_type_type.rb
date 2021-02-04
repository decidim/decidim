# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents an AssembliesType.
    class AssembliesTypeType < Decidim::Api::Types::BaseObject
      description "An assemblies type"

      field :id, GraphQL::Types::ID, "The assemblies type's unique ID", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this assemblies type.", null: false
      field :created_at, Decidim::Core::DateTimeType, "The time this assemblies type was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this assemblies type was updated", null: false
      field :assemblies, [Decidim::Assemblies::AssemblyType, { null: true }], "Assemblies with this assemblies type", null: false
    end
  end
end
