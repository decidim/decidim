# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      class BaseCell < Decidim::ViewModel
        include Decidim::LayoutHelper
        include Decidim::SanitizeHelper
        include Decidim::ComponentPathHelper
        include Decidim::Budgets::Engine.routes.url_helpers

        delegate :current_user, :parent_component_context, to: :controller
        delegate :current_settings, :settings, to: :group_component

        alias component model
        alias group_component model

        def workflow_instance
          @workflow_instance ||= parent_component_context[:workflow_instance]
        end

        def limit_reached?
          current_user && (workflow_instance.allowed - workflow_instance.progress).none?
        end
      end
    end
  end
end
