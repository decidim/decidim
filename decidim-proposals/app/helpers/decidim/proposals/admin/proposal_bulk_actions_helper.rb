# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module ProposalBulkActionsHelper
        def proposal_find(id)
          Decidim::Proposals::Proposal.find(id)
        end

        # find the valuators for the current space.
        def find_valuators_for_select(participatory_space, current_user)
          valuator_roles = participatory_space.user_roles(:valuator).order_by_name
          valuators = Decidim::User.where(id: valuator_roles.pluck(:decidim_user_id)).to_a

          filtered_valuator_roles = valuator_roles.filter do |role|
            role.decidim_user_id != current_user.id
          end

          filtered_valuator_roles.map do |role|
            valuator = valuators.find { |user| user.id == role.decidim_user_id }

            [valuator.name, role.id]
          end
        end
      end
    end
  end
end
