# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless permission_action.scope == :trustee_zone

          case permission_action.subject
          when :trustee
            toggle_allow(trustee?) if permission_action.action == :view
          when :user
            allow! if permission_action.action == :update_profile
          end

          permission_action
        end

        private

        def trustee?
          @trustee ||= Decidim::Elections::Trustee.trustee?(user)
        end
      end
    end
  end
end
