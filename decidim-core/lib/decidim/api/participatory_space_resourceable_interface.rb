# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a participatorySpaceResourceable object.
    # It create and array of linked participatory spaces for each registered manifest
    ParticipatorySpaceResourceableInterface = GraphQL::InterfaceType.define do
      name "ParticipatorySpaceResourcableInterface"
      description "An interface that can be used in objects with participatorySpaceResourceable"

      Decidim.participatory_space_manifests.each do |participatory_space_manifest|
        next unless participatory_space_manifest[:model_class_name].constantize.included_modules.include? Decidim::ParticipatorySpaceResourceable

        field "linked#{participatory_space_manifest.name.to_s.camelize}" do
          type types[participatory_space_manifest.query_type.constantize]
          description "Lists all linked #{participatory_space_manifest.name}"
          resolve lambda { |participatory_space, _args, _ctx|
            participatory_space.linked_participatory_space_resources(participatory_space_manifest.name, "included_#{participatory_space_manifest.name}")
          }
        end
      end
    end
  end
end
