# frozen_string_literal: true

module Decidim
  module Surveys
    module Abilities
      # Defines the abilities related to surveys for a logged in process admin user.
      # Intended to be used with `cancancan`.
      class ParticipatoryProcessAdminAbility < Decidim::Abilities::ParticipatoryProcessAdminAbility
        def define_participatory_process_abilities
          super

          can :manage, Survey do |survey|
            can_manage_process?(survey.feature.participatory_space)
          end
        end
      end
    end
  end
end
