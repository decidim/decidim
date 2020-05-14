# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :public

          if permission_action.action == :vote && permission_action.subject == :project
            can_vote_in_workflow?(false)
          elsif permission_action.action == :create && permission_action.subject == :order
            can_vote_in_workflow?(true)
          end

          permission_action
        end

        private

        def parent_component_context
          context[:parent_component_context]
        end

        def workflow_instance
          @workflow_instance ||= parent_component_context[:workflow_instance]
        end

        def can_vote_in_workflow?(active_allow)
          is_allowed = workflow_instance.vote_allowed?(component)

          if !is_allowed
            disallow!
          elsif active_allow
            allow!
          end
        end
      end
    end
  end
end
