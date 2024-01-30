# frozen_string_literal: true

module Decidim
  module Admin
    # Shared behaviour for signed_in admins that require the latest TOS accepted
    module NeedsAdminTosAccepted
      extend ActiveSupport::Concern

      included do
        before_action :tos_accepted_by_admin
      end

      private

      def tos_accepted_by_admin
        return unless request.format.html?
        return unless current_user
        return unless user_has_any_role?
        return if current_user.admin_terms_accepted?
        return if permitted_paths?

        store_location_for(
          current_user,
          request.path
        )
        redirect_to admin_tos_path
      end

      def permitted_paths?
        # ensure that path with or without query string pass
        permitted_paths.find { |el| el.split("?").first == request.path }
      end

      def permitted_paths
        [admin_tos_path, decidim_admin.admin_terms_accept_path]
      end

      def admin_tos_path
        decidim_admin.admin_terms_show_path
      end

      def user_has_any_role?
        return true if current_user.admin
        return true if current_user.roles.any?
        return true if participatory_process_user_role?
        return true if assembly_user_role?
        return true if conference_user_role?
        return true if voting_monitoring_commitee_member?

        false
      end

      def participatory_process_user_role?
        return false unless Decidim.module_installed?(:participatory_processes)

        true if Decidim::ParticipatoryProcessUserRole.exists?(user: current_user)
      end

      def assembly_user_role?
        return false unless Decidim.module_installed?(:assemblies)

        true if Decidim::AssemblyUserRole.exists?(user: current_user)
      end

      def conference_user_role?
        return false unless Decidim.module_installed?(:conferences)

        true if Decidim::ConferenceUserRole.exists?(user: current_user)
      end

      def voting_monitoring_commitee_member?
        return false unless Decidim.module_installed?(:elections)

        true if Decidim::Votings::MonitoringCommitteeMember.exists?(user: current_user)
      end
    end
  end
end
