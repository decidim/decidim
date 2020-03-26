# frozen_string_literal: true

module Decidim
  module Proposals
    # A set of methods and features related to proposal valuations.
    module Valuatable
      extend ActiveSupport::Concern
      include Decidim::Comments::Commentable

      included do
        has_many :valuation_assignments, foreign_key: "decidim_proposal_id", dependent: :destroy

        def valuators
          valuator_role_ids = valuation_assignments.where(proposal: self).pluck(:valuator_role_id)
          user_ids = participatory_space.user_roles(:valuator).where(id: valuator_role_ids).pluck(:decidim_user_id)
          participatory_space.organization.users.where(id: user_ids)
        end
      end
    end
  end
end
