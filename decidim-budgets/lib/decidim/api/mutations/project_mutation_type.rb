# frozen_string_string: true

module Decidim
  module Budgets
    class ProjectMutationType < Decidim::Api::Types::BaseObject
      description "Project mutations"
      graphql_name "ProjectMutation"

      include Decidim::Core::AttachableMutations
    end
  end
end
