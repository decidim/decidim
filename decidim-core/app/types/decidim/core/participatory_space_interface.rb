# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a ParticipatoryProcess.
    ParticipatorySpaceInterface = GraphQL::InterfaceType.define do
      name "ParticipatorySpaceInterface"
      description "A feature inside a participatory space"

      field :id, !types.ID, "The Feature's unique ID"

      field :title, !TranslatedFieldType, "The name of this feature."

      field :components, types[ComponentInterface] do
        resolve lambda do |participatory_space, _args, _ctx|
          Decidim::Feature.where(
            participatory_space: participatory_space
          ).published
        end
      end

      resolve_type lambda do |obj, _ctx|
        obj.manifest.api_type.constantize
      end
    end
  end
end
