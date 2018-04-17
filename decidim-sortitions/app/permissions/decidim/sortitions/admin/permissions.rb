# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin

          return permission_action if permission_action.subject != :sortition

          case permission_action.action
          when :destroy
            permission_action.allow! if sortition.present? && !sortition.cancelled?
          when :update
            permission_action.allow! if sortition.present?
          when :create, :read
            permission_action.allow!
          end

          permission_action
        end

        private

        def sortition
          @sortition ||= context.fetch(:sortition, nil)
        end
      end
    end
  end
end
