# frozen_string_literal: true

module Decidim
  module Debates
    module Abilities
      module Admin
        # Defines the abilities related to Debate for a logged in process admin user.
        # Intended to be used with `cancancan`.
        class ParticipatoryProcessModeratorAbility < Decidim::Abilities::ParticipatoryProcessModeratorAbility
          def define_participatory_process_abilities
            super

            can [:unreport, :hide], Debate do |debate|
              can_manage_process?(debate.component.participatory_space)
            end
          end
        end
      end
    end
  end
end
