# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      module VotingsAdminMenuHelper
        def admin_votings_components_menu
          @admin_votings_components_menu ||= simple_menu(target_menu: :admin_votings_components_menu, options: { container_options: { id: "components-list" } })
        end

        def decidim_votings_attachments_menu
          @decidim_votings_attachments_menu ||= simple_menu(target_menu: :decidim_votings_attachments_menu)
        end
      end
    end
  end
end
