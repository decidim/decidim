# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents an AssembliesType.
    AssembliesTypeType = GraphQL::ObjectType.define do
      name "AssembliesType"
      description "An assemblies type"

      field :id, !types.ID, "The assemblies type's unique ID"
      field :title, !Decidim::Core::TranslatedFieldType, "The title of this assemblies type."
      field :createdAt, !Decidim::Core::DateTimeType, "The time this assemblies type was created", property: :created_at
      field :updatedAt, !Decidim::Core::DateTimeType, "The time this assemblies type was updated", property: :updated_at
      field :assemblies, !types[Decidim::Assemblies::AssemblyType], "Assemblies with this assemblies type"
    end
  end
end
