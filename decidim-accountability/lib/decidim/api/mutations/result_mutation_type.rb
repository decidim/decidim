# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultMutationType < Decidim::Api::Types::BaseObject
      graphql_name "ResultMutation"
      description "Result mutation"

      field :delete, mutation: DeleteResultType, description: "Deletes a result"
      field :update, mutation: UpdateResultType, description: "Updates a result"

      field :create_milestone, mutation: CreateMilestoneType, description: "Creates a milestone"
      field :delete_milestone, mutation: Decidim::Accountability::DeleteMilestoneType, description: "Deletes a milestone"
      field :update_milestone, mutation: UpdateMilestoneType, description: "Updates a milestone"
    end
  end
end
