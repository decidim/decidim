# frozen_string_literal: true

module Decidim
  module Demographics
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user
        return permission_action unless permission_action.scope == :public
        return permission_action unless permission_action.subject == :demographics

        toggle_allow(demographic.collect_data?) if permission_action.action == :respond

        permission_action
      end

      private

      def demographic
        @demographic ||= Decidim::Demographics::Demographic.where(organization: user.organization).first_or_initialize
      end
    end
  end
end
