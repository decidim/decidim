# frozen_string_literal: true

module Decidim
  module Budgets
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Budgets::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action unless [:project, :order].include? permission_action.subject

        if permission_action.subject == :project
          case permission_action.action
          when :vote
            can_vote?(false) if can_vote_project?(project || order&.projects&.first)
          when :report
            permission_action.allow!
          end
        end

        can_vote?(true) if permission_action.action == :create && permission_action.subject == :order

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
    end
  end
end
