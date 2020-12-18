# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # Custom helpers for answers on admin dashboard.
      #
      module AnswersHelper
        def selected_label_action_for(answer)
          if answer.selected
            t("answers.select.disable", scope: "decidim.elections.admin")
          else
            t("answers.select.enable", scope: "decidim.elections.admin")
          end
        end
      end
    end
  end
end
