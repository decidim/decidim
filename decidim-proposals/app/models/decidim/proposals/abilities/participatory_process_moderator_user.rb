# frozen_string_literal: true

module Decidim
  module Proposals
    module Abilities
      # Defines the abilities related to proposals for a logged in process admin user.
      # Intended to be used with `cancancan`.
      class ParticipatoryProcessModeratorUser < Decidim::Abilities::ParticipatoryProcessModeratorUser
        def define_participatory_process_abilities
          super

          can [:unreport, :hide], Proposal do |proposal|
            can_manage_process?(proposal.feature.participatory_process)
          end
        end
      end
    end
  end
end
