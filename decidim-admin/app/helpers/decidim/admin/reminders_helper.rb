# frozen_string_literal: true

module Decidim
  module Admin
    module RemindersHelper
      # Route to the correct reminder for a component.
      def admin_reminders_path(component, options = {})
        EngineRouter.admin_proxy(component.participatory_space).new_component_reminder_path(options.merge(component_id: component))
      end
    end
  end
end
