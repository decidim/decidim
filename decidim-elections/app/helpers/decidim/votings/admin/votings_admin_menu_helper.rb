# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      module VotingsAdminMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_votings_components_menu
          @admin_votings_components_menu ||= simple_menu(:admin_votings_components_menu)
        end

        def decidim_votings_attachments_menu
          @decidim_votings_attachments_menu ||= simple_menu(:decidim_votings_attachments_menu)
        end

        def decidim_voting_menu
          @decidim_voting_menu ||= sidebar_menu(:decidim_voting_menu)
        end
      end
    end
  end
end
