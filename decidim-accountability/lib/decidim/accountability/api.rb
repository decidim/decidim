# frozen_string_literal: true

module Decidim
  module Accountability
    autoload :AccountabilityType, "decidim/api/accountability_type"
    autoload :ResultType, "decidim/api/result_type"
    autoload :StatusType, "decidim/api/status_type"
    autoload :MilestoneType, "decidim/api/milestone_type"
    autoload :AccountabilityMutationType, "decidim/api/mutations/accountablity_mutation_type"
  end
end
