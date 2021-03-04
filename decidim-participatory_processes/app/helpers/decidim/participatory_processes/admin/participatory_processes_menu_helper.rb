# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      module ParticipatoryProcessesMenuHelper
        def admin_participatory_process_attachments_menu
          @admin_participatory_process_attachments_menu ||= simple_menu(target_menu: :admin_participatory_process_attachments_menu)
        end

        def admin_participatory_process_components_menu
          @admin_participatory_process_components_menu ||= simple_menu(target_menu: :admin_participatory_process_components_menu, options: { container_options: { id: "components-list" } })
        end
      end
    end
  end
end
