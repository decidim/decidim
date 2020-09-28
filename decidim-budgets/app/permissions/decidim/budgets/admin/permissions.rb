# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          case permission_action.subject
          when :budget
            case permission_action.action
            when :create, :read
              allow!
            when :update
              toggle_allow(budget)
            when :delete, :publish, :unpublish
              toggle_allow(budget && budget.projects.empty?)
            end
          when :project, :projects
            case permission_action.action
            when :create
              permission_action.allow!
            when :import_proposals
              permission_action.allow!
            when :update, :destroy
              permission_action.allow! if project.present?
            end
          end

          permission_action
        end

        private

        def budget
          @budget ||= context.fetch(:budget, nil)
        end

        def project
          @project ||= context.fetch(:project, nil)
        end
      end
    end
  end
end
