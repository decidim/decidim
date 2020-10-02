# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # Custom helpers for trustees admin.
      #
      module TrusteesHelper
        def trustee_current_participatory_space(trustee)
          trustee.trustees_participatory_spaces.find_by(participatory_space: current_participatory_space)
        end

        def considered_icon_action_for(trustee)
          if trustee_current_participatory_space(trustee).considered
            "x"
          else
            "check"
          end
        end

        def considered_label_action_for(trustee)
          if trustee_current_participatory_space(trustee).considered
            t("trustee_participatory_space.actions.disable", scope: "decidim.elections.admin")
          else
            t("trustee_participatory_space.actions.enable", scope: "decidim.elections.admin")
          end
        end
      end
    end
  end
end
