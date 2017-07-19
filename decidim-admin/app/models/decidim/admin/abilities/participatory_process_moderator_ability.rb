# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a moderator user in the admin
      # section. Intended to be used with `cancancan`.
      class ParticipatoryProcessModeratorAbility < Decidim::Abilities::ParticipatoryProcessModeratorAbility
        def define_abilities
          super

          can [:read], ParticipatoryProcess do |process|
            can_manage_process?(process)
          end

          can :manage, Moderation do |moderation|
            can_manage_process?(moderation.participatory_process)
          end
        end
      end
    end
  end
end
