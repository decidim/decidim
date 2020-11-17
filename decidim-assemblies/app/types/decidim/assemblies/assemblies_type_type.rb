# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents an AssembliesType.
    class AssembliesTypeType < GraphQL::Schema::Object
      graphql_name"AssembliesType"
      implements Decidim::Core::TimestampsInterface

      description "An assemblies type"

      field :id, ID, null: false, description:  "The assemblies type's unique ID"
      field :title, Decidim::Core::TranslatedFieldType,null: false, description:  "The title of this assemblies type."
      field :assemblies, [Decidim::Assemblies::AssemblyType], null: false, description: "Assemblies with this assemblies type"
    end
  end
end
