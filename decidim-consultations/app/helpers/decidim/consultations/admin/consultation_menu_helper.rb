# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      module ConsultationMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_consultation_menu
          @admin_consultation_menu ||= sidebar_menu(:admin_consultation_menu)
        end
      end
    end
  end
end
