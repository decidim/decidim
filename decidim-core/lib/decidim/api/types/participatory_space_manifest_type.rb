# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceManifestType < Decidim::Api::Types::BaseObject
      description "A participatory manifest"

      field :name, GraphQL::Types::String, "The name of the manifest", null: false
      field :human_name, Decidim::Core::QuantifiableTranslatedFieldType, "The human readable name for the manifest", null: false

      def human_name
        {
          single: object.human_name,
          plural: object.human_name(count: 2)
        }
      end
    end
  end
end
