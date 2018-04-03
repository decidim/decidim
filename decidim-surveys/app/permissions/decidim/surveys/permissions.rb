# frozen_string_literal: true

module Decidim
  module Surveys
    class Permissions < Decidim::DefaultPermissions
      def allowed?
        # Stop checks if the user is not authorized to perform the
        # permission_action for this space
        return false unless spaces_allows_user?
        return false unless user

        return Decidim::Surveys::Admin::Permissions.new(user, permission_action, context).allowed? if permission_action.scope == :admin
        return false if permission_action.scope != :public

        return false if permission_action.subject != :survey

        return true if case permission_action.action
                       when :answer
                         authorized?(:answer)
                       else
                         false
                       end

        false
      end
    end
  end
end
