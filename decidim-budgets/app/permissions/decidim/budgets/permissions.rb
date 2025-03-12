# frozen_string_literal: true

module Decidim
  module Budgets
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Budgets::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        case [permission_action.action, permission_action.subject]
        when [:vote, :project]
          can_vote?(false) if can_vote_project?(project || order&.projects&.first)
        when [:report, :project]
          permission_action.allow!
        when [:read, :project]
          toggle_allow(project.visible?)
        when [:create, :order]
          can_vote?(true)
        when [:export_pdf, :order]
          can_export_pdf?
        end

        permission_action
      end

      private

      def project
        @project ||= context.fetch(:project, nil)
      end

      def order
        @order ||= context.fetch(:order, nil)
      end

      def budget
        @budget ||= context.fetch(:budget, nil)
      end

      def workflow
        @workflow ||= context.fetch(:workflow, nil)
      end

      def can_vote?(active_allow)
        is_allowed = workflow.vote_allowed?(budget)

        if !is_allowed
          disallow!
        elsif active_allow
          allow!
        end
      end

      def can_vote_project?(a_project)
        is_allowed = a_project && authorized?(:vote, resource: project)

        toggle_allow(is_allowed)
      end

      def can_export_pdf?
        is_allowed = order.user == user

        toggle_allow(is_allowed)
      end
    end
  end
end
