# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultMutationType < Decidim::Api::Types::BaseObject
      graphql_name "ResultMutation"
      description "Accountability result mutations"

      field :create_milestone, mutation: CreateMilestoneType, description: "create milestone"
      field :delete_milestone, mutation: Decidim::Accountability::DeleteMilestoneType, description: "delete milestone"
      field :update_milestone, mutation: UpdateMilestoneType, description: "update milestone"
    end
  end
end
