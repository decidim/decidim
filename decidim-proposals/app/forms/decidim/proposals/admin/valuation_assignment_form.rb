# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ValuationAssignmentForm < Decidim::Form
        attribute :id, Integer
        attribute :proposal_ids, Array
        attribute :valuator_role_ids, Array

        validates :valuator_roles, :proposals, :current_component, presence: true
        validate :same_participatory_space

        def proposals
          @proposals ||= Decidim::Proposals::Proposal.where(component: current_component, id: proposal_ids).uniq
        end

        def valuator_roles
          @valuator_roles ||= current_component.participatory_space
                                               .user_roles(:valuator)
                                               .order_by_name
                                               .where(id: valuator_role_ids)
        end

        def same_participatory_space
          return if valuator_roles.empty? || !current_component

          valuator_roles.each do |valuator_role|
            if current_component.participatory_space != valuator_role.participatory_space
              errors.add(:id, :invalid)
              break
            end
          end
        end
      end
    end
  end
end
