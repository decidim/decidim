# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class EvaluationAssignmentForm < Decidim::Form
        attribute :id, Integer
        attribute :proposal_ids, Array
        attribute :evaluator_role_ids, Array

        validates :evaluator_roles, :proposals, :current_component, presence: true
        validate :same_participatory_space

        def proposals
          @proposals ||= Decidim::Proposals::Proposal.where(component: current_component, id: proposal_ids).uniq
        end

        def evaluator_roles
          @evaluator_roles ||= current_component.participatory_space
                                                .user_roles(:evaluator)
                                                .order_by_name
                                                .where(id: evaluator_role_ids)
        end

        def same_participatory_space
          return if evaluator_roles.empty? || !current_component

          evaluator_roles.each do |evaluator_role|
            if current_component.participatory_space != evaluator_role.participatory_space
              errors.add(:id, :invalid)
              break
            end
          end
        end
      end
    end
  end
end
