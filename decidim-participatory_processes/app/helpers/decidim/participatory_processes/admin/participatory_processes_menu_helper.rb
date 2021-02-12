# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      module ParticipatoryProcessesMenuHelper
        def participatory_process_menu
          @participatory_process_menu ||= sidebar_menu(:admin_participatory_process_menu)
        end

        def participatory_process_group_menu
          @participatory_process_group_menu ||= sidebar_menu(:admin_participatory_process_group_menu)
        end

        def participatory_processes_menu
          @participatory_processes_menu ||= sidebar_menu(:admin_participatory_processes_menu)
        end

        protected

        def sidebar_menu(target_menu)
          ::Decidim::Admin::SecondaryMenuPresenter.new(target_menu, self, active_class: "is-active")
        end
      end
    end
  end
end
