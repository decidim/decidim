# frozen_string_literal: true

module Decidim
  module Core
    ParticipatorySpaceInterface = GraphQL::InterfaceType.define do
      name "ParticipatorySpaceInterface"
      description "The interface that all participatory spaces should implement."

      field :id, !types.ID, "The participatory space's unique ID"

      field :title, !TranslatedFieldType, "The name of this participatory space."

      field :components, types[ComponentInterface] do
        description "Lists the components this space contains."

        resolve ->(participatory_space, _args, _ctx) {
                  Decidim::Feature.where(
                    participatory_space: participatory_space
                  ).published
                }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.api_type.constantize }
    end
  end
end
