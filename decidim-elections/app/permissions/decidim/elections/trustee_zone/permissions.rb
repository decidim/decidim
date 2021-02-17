# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless permission_action.scope == :trustee_zone

          case permission_action.subject
          when :trustee, :election
            toggle_allow(trustee_for_user?) if [:view, :update].member?(permission_action.action)
          when :user
            allow! if permission_action.action == :update_profile
          end

          permission_action
        end

        private

        def trustee_for_user?
          trustee && trustee.user == user
        end

        def trustee
          @trustee ||= context.fetch(:trustee, nil)
        end
      end
    end
  end
end
