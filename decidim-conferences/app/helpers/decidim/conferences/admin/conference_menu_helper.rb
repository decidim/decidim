# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      module ConferenceMenuHelper
        def admin_conferences_components_menu
          @admin_conferences_components_menu ||= simple_menu(target_menu: :admin_conferences_components_menu, options: { container_options: { id: "components-list" } })
        end

        def conferences_admin_registrations_menu
          @conferences_admin_registrations_menu ||= simple_menu(target_menu: :conferences_admin_registrations_menu)
        end

        def conferences_admin_attachments_menu
          @conferences_admin_attachments_menu ||= simple_menu(target_menu: :conferences_admin_attachments_menu)
        end
      end
    end
  end
end
