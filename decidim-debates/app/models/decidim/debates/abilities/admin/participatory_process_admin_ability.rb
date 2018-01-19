# frozen_string_literal: true

module Decidim
  module Debates
    module Abilities
      module Admin
        # Defines the abilities related to debates for a logged in process admin user.
        # Intended to be used with `cancancan`.
        class ParticipatoryProcessAdminAbility < Decidim::Abilities::ParticipatoryProcessAdminAbility
          def define_participatory_process_abilities
            super

            can :manage, Debate do |debate|
              debate.author.blank?
            end
            can :unreport, Debate
            can :hide, Debate
          end
        end
      end
    end
  end
end
