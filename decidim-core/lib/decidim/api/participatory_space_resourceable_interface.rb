# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a participatorySpaceResourceable object.
    # It create and array of linked participatory spaces for each registered manifest
    ParticipatorySpaceResourceableInterface = GraphQL::InterfaceType.define do
      name "ParticipatorySpaceResourcableInterface"
      description "An interface that can be used in objects with participatorySpaceResourceable"

      # this handles the cases linked_participatory_space_resources(:participatory_space, :included_participatory_space)
      field "linkedParticipatorySpaces", !types[ParticipatorySpaceLinkType] do
        description "Lists all linked participatory spaces in a polymorphic way"
        resolve ->(participatory_space, _args, _ctx) {
          Decidim::ParticipatorySpaceLink.where("name like 'included_%' and ((from_id=:id and from_type=:type) or (to_id=:id and to_type=:type))",
                                                id: participatory_space.id, type: participatory_space.class.name)
        }
      end
    end
  end
end
