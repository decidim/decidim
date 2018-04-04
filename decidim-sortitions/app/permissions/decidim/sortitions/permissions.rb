# frozen_string_literal: true

module Decidim
  module Sortitions
    class Permissions < Decidim::DefaultPermissions
      def allowed?
        return false unless spaces_allows_user?
        return false unless user

        return Decidim::Sortitions::Admin::Permissions.new(user, permission_action, context).allowed? if permission_action.scope == :admin

        false
      end
    end
  end
end
