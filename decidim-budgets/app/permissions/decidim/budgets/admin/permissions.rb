# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          return permission_action unless [:project, :projects].include?(permission_action.subject)

          case permission_action.action
          when :create
            permission_action.allow!
          when :import_proposals
            permission_action.allow!
          when :update, :destroy
            permission_action.allow! if project.present?
          end

          permission_action
        end

        private

        def project
          @project ||= context.fetch(:project, nil)
        end
      end
    end
  end
end
