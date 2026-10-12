# frozen_string_literal: true

module Decidim
  module Demographics
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user
        return permission_action unless permission_action.scope == :public
        return permission_action unless permission_action.subject == :demographics

        case permission_action.action
        when :read, :destroy
          allow!
        when :respond
          toggle_allow(demographic.collect_data?)
        end

        permission_action
      end

      private

      def demographic
        @demographic ||= Decidim::Demographics::Demographic.where(organization: user.organization).first_or_initialize
      end
    end
  end
end
