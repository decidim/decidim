# frozen_string_literal: true

module Decidim
  module Debates
    class Permissions < Decidim::DefaultPermissions
      def allowed?
        # Stop checks if the user is not authorized to perform the
        # permission_action for this space
        return false unless spaces_allows_user?
        return false unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Debates::Admin::Permissions.new(user, permission_action, context).allowed? if permission_action.scope == :admin
        return false if permission_action.scope != :public

        return false if permission_action.subject != :debate

        return true if case permission_action.action
                       when :create
                         can_create_debate?
                       when :report
                         true
                       else
                         false
                       end

        false
      end

      private

      def can_create_debate?
        authorized?(:create) &&
          current_settings&.creation_enabled?
      end
    end
  end
end
