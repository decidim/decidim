# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      module ConferenceMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_conferences_components_menu
          @admin_conferences_components_menu ||= simple_menu(:admin_conferences_components_menu)
        end

        def conferences_admin_registrations_menu
          @conferences_admin_registrations_menu ||= simple_menu(:conferences_admin_registrations_menu)
        end

        def conferences_admin_attachments_menu
          @conferences_admin_attachments_menu ||= simple_menu(:conferences_admin_attachments_menu)
        end

        def conferences_admin_menu
          @conferences_admin_menu ||= sidebar_menu(:conferences_admin_menu)
        end
      end
    end
  end
end
