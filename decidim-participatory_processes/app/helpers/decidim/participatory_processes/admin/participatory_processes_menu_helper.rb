# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      module ParticipatoryProcessesMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def participatory_process_menu
          @participatory_process_menu ||= sidebar_menu(:admin_participatory_process_menu)
        end

        def participatory_process_group_menu
          @participatory_process_group_menu ||= sidebar_menu(:admin_participatory_process_group_menu)
        end

        def participatory_processes_menu
          @participatory_processes_menu ||= sidebar_menu(:admin_participatory_processes_menu)
        end
      end
    end
  end
end
