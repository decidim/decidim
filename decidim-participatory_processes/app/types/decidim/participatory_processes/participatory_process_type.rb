# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    ParticipatoryProcessType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ParticipatorySpaceInterface },
        -> { Decidim::Core::AttachableInterface }
      ]

      name "ParticipatoryProcess"
      description "A participatory process"

      field :steps, !types[ParticipatoryProcessStepType], "All the steps of this process."
    end
  end
end
