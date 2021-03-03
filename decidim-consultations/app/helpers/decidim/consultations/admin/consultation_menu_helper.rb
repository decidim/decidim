# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      module ConsultationMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_consultation_components_menu
          @admin_consultation_components_menu ||= simple_menu(:admin_consultation_components_menu)
        end

        def admin_questions_menu
          @admin_questions_menu ||= simple_menu(:admin_questions_menu)
        end

        def admin_consultation_question_menu
          @admin_consultation_question_menu ||= sidebar_menu(:admin_consultation_question_menu)
        end

        def admin_consultation_menu
          @admin_consultation_menu ||= sidebar_menu(:admin_consultation_menu)
        end
      end
    end
  end
end
