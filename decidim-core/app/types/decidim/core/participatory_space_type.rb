# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a ParticipatoryProcess.
    ParticipatorySpaceType = GraphQL::ObjectType.define do
      interfaces [-> { ParticipatorySpaceInterface }]

      name "ParticipatorySpace"
      description "A participatory space"
    end
  end
end
