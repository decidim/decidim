# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This cell renders the Budgets Group header
      class BudgetsGroupHeaderCell < BaseCell
        include BudgetsGroupsHelper

        delegate :highlighted, :voted, to: :workflow_instance

        def title
          translated_attribute(current_settings.title).presence || translated_attribute(settings.title)
        end

        def description
          translated_attribute(current_settings.description).presence || translated_attribute(settings.description)
        end

        def voted?
          current_user && workflow_instance.voted.any?
        end

        def finished?
          current_user && (workflow_instance.allowed - workflow_instance.voted).none?
        end

        def highlighted_heading
          translated_attribute(current_settings.highlighted_heading).presence || translated_attribute(settings.highlighted_heading)
        end

        def order_path_for(component)
          ::Decidim::EngineRouter.main_proxy(component).order_path
        end
      end
    end
  end
end
