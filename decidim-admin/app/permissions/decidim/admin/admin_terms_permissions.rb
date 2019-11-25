# frozen_string_literal: true

module Decidim
  module Admin
    class AdminTermsPermissions < Decidim::DefaultPermissions
      def permissions
        if no_need_to_agree_admin_terms_action?
          allow!
        # elsif permission_action.subject.to_s.exclude?("initiative")
        #   # toggle_allow(user.admin_terms_accepted?)
        # else
        end
        allow! if user_admin_terms_accepted?


        permission_action
      end

      private

      def user_admin_terms_accepted?
        user && user.admin_terms_accepted?
      end

      def read_admin_dashboard_action?
        permission_action.subject == :admin_dashboard &&
          permission_action.action == :read
      end

      def no_need_to_agree_admin_terms_action?
        return true if read_admin_dashboard_action?
        return true if context[:space_name] == :initiatives
        # return true if permission_action.subject == :initiative
        # return true if permission_action.subject == :initiative_type
      end

      def organization
        @organization ||= context.fetch(:organization, nil) || context.fetch(:current_organization, nil)
      end
    end
  end
end
