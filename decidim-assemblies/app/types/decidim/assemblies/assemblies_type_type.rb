# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents an AssembliesType.
    AssembliesTypeType = GraphQL::ObjectType.define do
      implements Decidim::Core::TimestampsInterface

      name "AssembliesType"
      description "An assemblies type"

      field :id, !types.ID, "The assemblies type's unique ID"
      field :title, !Decidim::Core::TranslatedFieldType, "The title of this assemblies type."
      field :assemblies, !types[Decidim::Assemblies::AssemblyType], "Assemblies with this assemblies type"
    end
  end
end
