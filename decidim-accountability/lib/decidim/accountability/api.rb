# frozen_string_literal: true

module Decidim
  module Accountability
    autoload :AccountabilityType, "decidim/api/accountability_type"
    autoload :ResultType, "decidim/api/result_type"
    autoload :StatusType, "decidim/api/status_type"
    autoload :MilestoneType, "decidim/api/milestone_type"
    # mutations
    autoload :AccountabilityMutationType, "decidim/api/mutations/accountability_mutation_type"
    autoload :CreateResultType, "decidim/api/mutations/result/create_result_type"
    autoload :UpdateResultType, "decidim/api/mutations/result/update_result_type"
    autoload :DeleteResultType, "decidim/api/mutations/result/delete_result_type"
    autoload :ResultAttributes, "decidim/api/mutations/result/result_attributes"
    autoload :ResultMutationType, "decidim/api/mutations/result_mutation_type"
    autoload :CreateMilestoneType, "decidim/api/mutations/milestone/create_milestone_type"
    autoload :UpdateMilestoneType, "decidim/api/mutations/milestone/update_milestone_type"
    autoload :DeleteMilestoneType, "decidim/api/mutations/milestone/delete_milestone_type"
    autoload :MilestoneAttributes, "decidim/api/mutations/milestone/milestone_attributes"
  end
end
