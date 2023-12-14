# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # Custom helpers for election steps on admin dashboard.
      #
      module StepsHelper
        def steps(current_step)
          step_class = "text-success"
          (["create_election"] + Decidim::Elections::Election.bb_statuses.keys).map do |step|
            if step == current_step
              step_class = "text-muted"
              [step, "text-warning"]
            else
              [step, step_class]
            end
          end
        end

        def fix_it_button_with_icon(link, icon_name, method = :get)
          link_to(link, class: "button tiny button__secondary px-2 py-0", method:) do
            "#{icon(icon_name, class: "fix-icon")} #{I18n.t("decidim.elections.admin.steps.create_election.errors.fix_it_text")}".html_safe
          end
        end

        # i18n-tasks-use t("decidim.elections.admin.steps.create_election.technical_configuration.bulletin_board_server")
        # i18n-tasks-use t("decidim.elections.admin.steps.create_election.technical_configuration.authority_name")
        # i18n-tasks-use t("decidim.elections.admin.steps.create_election.technical_configuration.scheme_name")
        def technical_configuration_items
          [
            { key: ".technical_configuration.bulletin_board_server", value: Decidim::BulletinBoard.config[:bulletin_board_server] },
            { key: ".technical_configuration.authority_name", value: Decidim::BulletinBoard.config[:authority_name] },
            { key: ".technical_configuration.scheme_name", value: Decidim::BulletinBoard.config[:scheme_name] }
          ]
        end
      end
    end
  end
end
