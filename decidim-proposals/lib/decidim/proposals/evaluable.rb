# frozen_string_literal: true

module Decidim
  module Proposals
    # A set of methods and features related to proposal evaluations.
    module Evaluable
      extend ActiveSupport::Concern
      include Decidim::Comments::Commentable

      included do
        has_many :evaluation_assignments, foreign_key: "decidim_proposal_id", dependent: :destroy,
                                          counter_cache: :evaluation_assignments_count, class_name: "Decidim::Proposals::EvaluationAssignment"

        def evaluators
          evaluator_role_ids = evaluation_assignments.where(proposal: self).pluck(:evaluator_role_id)
          user_ids = participatory_space.user_roles(:evaluator).where(id: evaluator_role_ids).pluck(:decidim_user_id)
          participatory_space.organization.users.where(id: user_ids)
        end
      end
    end
  end
end
