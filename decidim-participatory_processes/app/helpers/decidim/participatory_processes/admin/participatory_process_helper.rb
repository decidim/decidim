# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Helpers related to the Admin of Participatory Process layout.
      module ParticipatoryProcessHelper
        def scope_type_depth_select_options
          {
            include_blank: true,
            selected: current_participatory_process.try(:decidim_scope_type_id)
          }
        end

        def scope_type_depth_select_html_options
          html_options = {}
          html_options[:disabled] = "disabled" unless current_participatory_process.try(:scopes_enabled)
          html_options
        end
      end
    end
  end
end
