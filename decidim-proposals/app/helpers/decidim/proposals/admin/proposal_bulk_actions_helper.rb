# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module ProposalBulkActionsHelper
        # Public: Generates a select field with the valuators of the given participatory space.
        #
        # participatory_space - A participatory space instance.
        #
        # Returns a String.
        def bulk_valuators_select(participatory_space)
          valuator_roles = participatory_space.user_roles(:valuator)
          valuators = Decidim::User.where(id: valuator_roles.pluck(:decidim_user_id)).to_a

          options_for_select = valuator_roles.map do |role|
            valuator = valuators.find { |user| user.id == role.decidim_user_id }

            [valuator.name, role.id]
          end
          prompt = t("decidim.proposals.admin.proposals.index.assign_to_valuator")

          select(:valuator_role, :id, options_for_select, prompt: prompt)
        end
      end
    end
  end
end
