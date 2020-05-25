# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This cell renders the Budgets Group "More information" modal dialog
      class BudgetsGroupInformationModalCell < BudgetsGroupHeaderCell
        def group_component
          component.parent
        end

        def more_information
          translated_attribute(current_settings.more_information).presence || translated_attribute(settings.more_information)
        end

        def group_name
          translated_attribute(group_component.name)
        end

        def discardable
          @discardable ||= if should_discard_to_vote?
                             workflow_instance.discardable - [component]
                           else
                             []
                           end
        end

        def order_path_for(component)
          ::Decidim::EngineRouter.main_proxy(component).order_path(return_path: request.path)
        end

        def should_discard_to_vote?
          limit_reached? && workflow_instance.vote_allowed?(component, false)
        end
      end
    end
  end
end
