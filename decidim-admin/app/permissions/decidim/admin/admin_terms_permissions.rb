# frozen_string_literal: true

module Decidim
  module Admin
    class AdminTermsPermissions < Decidim::DefaultPermissions
      def permissions
        if no_need_to_agree_admin_terms_action? || user_admin_terms_accepted?
          allow! unless admin_initiative_subject?
        else
          disallow!
        end

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

      def admin_terms_of_use_subject?
        permission_action.subject == :admin_terms_of_use
      end

      def admin_initiative_subject?
        permission_action.subject.to_s.include?("initiative")
      end

      def no_need_to_agree_admin_terms_action?
        return true unless permission_action.scope == :admin
        return true if read_admin_dashboard_action?
        return true if admin_terms_of_use_subject?
        return true if admin_initiative_subject?
        return true if context[:space_name] == :initiatives
      end
    end
  end
end
