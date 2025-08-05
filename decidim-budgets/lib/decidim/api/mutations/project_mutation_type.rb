# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectMutationType < Decidim::Api::Types::BaseObject
      description "Project mutations"
      graphql_name "ProjectMutation"

      include Decidim::Core::AttachableMutations
      include Decidim::Core::AttachableCollectionMutations
    end
  end
end
