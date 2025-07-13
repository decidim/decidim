# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          return permission_action if permission_action.subject != :collaborative_text

          case permission_action.action
          when :update, :read, :create, :destroy
            allow!
          end

          permission_action
        end

        private

        def document
          @document ||= context.fetch(:document, nil)
        end
      end
    end
  end
end
