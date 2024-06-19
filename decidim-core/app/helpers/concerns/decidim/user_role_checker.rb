# frozen_string_literal: true

module Decidim
  module UserRoleChecker
    # Shared behaviour for signed_in admins
    extend ActiveSupport::Concern

    private

    def user_has_any_role?(user)
      return true if user.admin
      return true if user.roles.any?
      return true if participatory_process_user_role?(user)
      return true if assembly_user_role?(user)
      return true if conference_user_role?(user)

      false
    end

    def participatory_process_user_role?(user)
      return false unless Decidim.module_installed?(:participatory_processes)

      true if Decidim::ParticipatoryProcessUserRole.exists?(user:)
    end

    def assembly_user_role?(user)
      return false unless Decidim.module_installed?(:assemblies)

      true if Decidim::AssemblyUserRole.exists?(user:)
    end

    def conference_user_role?(user)
      return false unless Decidim.module_installed?(:conferences)

      true if Decidim::ConferenceUserRole.exists?(user:)
    end
  end
end
