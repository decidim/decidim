# frozen_string_literal: true

module Decidim
  module Proposals
    # An evaluation assignment links a proposal and an Evaluator user role.
    # Evaluators will be users in charge of defining the monetary cost of a
    # proposal.
    class EvaluationAssignment < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal",
                            counter_cache: true
      belongs_to :evaluator_role, polymorphic: true

      def self.log_presenter_class_for(_log)
        Decidim::Proposals::AdminLog::EvaluationAssignmentPresenter
      end

      def evaluator
        evaluator_role.user
      end
    end
  end
end
