# frozen_string_literal: true

module Decidim
  module Comments
    module Abilities
      # Defines the abilities related to comments for a logged in process admin user.
      # Intended to be used with `cancancan`.
      class ParticipatoryProcessAdminUser < Decidim::Abilities::ParticipatoryProcessAdminUser
        def define_participatory_process_abilities
          super

          can [:manage, :unreport, :hide], Comment do |comment|
            can_manage_process?(comment.feature.participatory_process)
          end
        end
      end
    end
  end
end
