# frozen_string_literal: true

module Decidim
  module UserRoleChecker
    # Shared behaviour for signed_in admins
    extend ActiveSupport::Concern

    private

    def user_has_any_role?(user, participatory_space = nil, broad_check: false)
      return false unless user

      [
        user.admin,
        user.roles.any?,
        participatory_process_user_role?(user, participatory_space, broad_check:),
        assembly_user_role?(user, participatory_space, broad_check:),
        conference_user_role?(user, participatory_space, broad_check:)
      ].any?
    end

    def participatory_process_user_role?(user, participatory_process = nil, broad_check: false)
      return false unless Decidim.module_installed?(:participatory_processes)
      return Decidim::ParticipatoryProcessUserRole.exists?(user:) if broad_check
      return false unless participatory_process.is_a?(Decidim::ParticipatoryProcess)

      Decidim::ParticipatoryProcessUserRole.exists?(user:, participatory_process:)
    end

    def assembly_user_role?(user, assembly = nil, broad_check: false)
      return false unless Decidim.module_installed?(:assemblies)
      return Decidim::AssemblyUserRole.exists?(user:) if broad_check
      return false unless assembly.is_a?(Decidim::Assembly)

      Decidim::AssemblyUserRole.exists?(user:, assembly:)
    end

    def conference_user_role?(user, conference = nil, broad_check: false)
      return false unless Decidim.module_installed?(:conferences)
      return Decidim::ConferenceUserRole.exists?(user:) if broad_check
      return false unless conference.is_a?(Decidim::Conference)

      Decidim::ConferenceUserRole.exists?(user:, conference:)
    end
  end
end
