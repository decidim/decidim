# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      module ConsultationMenuHelper
        def admin_consultation_components_menu
          @admin_consultation_components_menu ||= simple_menu(target_menu: :admin_consultation_components_menu, options: { container_options: { id: "components-list" } })
        end

        def admin_questions_menu
          @admin_questions_menu ||= simple_menu(target_menu: :admin_questions_menu)
        end
      end
    end
  end
end
