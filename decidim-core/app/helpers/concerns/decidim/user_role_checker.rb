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
      return false unless participatory_process.is_a?(Decidim::ParticipatoryProcess)

      if broad_check
        Decidim::ParticipatoryProcessUserRole.exists?(user:)
      else
        Decidim::ParticipatoryProcessUserRole.exists?(user:, participatory_process:)
      end
    end

    def assembly_user_role?(user, assembly = nil, broad_check: false)
      return false unless Decidim.module_installed?(:assemblies)
      return false unless assembly.is_a?(Decidim::Assembly)

      if broad_check
        Decidim::AssemblyUserRole.exists?(user:)
      else
        Decidim::AssemblyUserRole.exists?(user:, assembly:)
      end
    end

    def conference_user_role?(user, conference = nil, broad_check: false)
      return false unless Decidim.module_installed?(:conferences)
      return false unless conference.is_a?(Decidim::Conference)

      if broad_check
        Decidim::ConferenceUserRole.exists?(user:)
      else
        Decidim::ConferenceUserRole.exists?(user:, conference:)
      end
    end
  end
end
