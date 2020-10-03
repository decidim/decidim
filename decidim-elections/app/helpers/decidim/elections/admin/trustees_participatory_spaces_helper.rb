# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # Custom helpers for trustees admin.
      #
      module TrusteesParticipatorySpacesHelper
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
            t("trustees_participatory_spaces.actions.disable", scope: "decidim.elections.admin")
          else
            t("trustees_participatory_spaces.actions.enable", scope: "decidim.elections.admin")
          end
        end
      end
    end
  end
end
