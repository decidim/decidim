# frozen_string_literal: true

module Decidim
  module UserRoleChecker
    # Shared behaviour for signed_in admins
    extend ActiveSupport::Concern

    private

    def user_has_any_role?(user, participatory_space = nil)
      return false unless user

      [
        user.admin,
        user.roles.any?,
        participatory_process_user_role?(user, participatory_space),
        assembly_user_role?(user, participatory_space),
        conference_user_role?(user, participatory_space)
      ].any?
    end

    def participatory_process_user_role?(user, participatory_process = nil)
      return false unless Decidim.module_installed?(:participatory_processes)

      if participatory_process.is_a?(Decidim::ParticipatoryProcess)
        Decidim::ParticipatoryProcessUserRole.exists?(user:, participatory_process:)
      else
        Decidim::ParticipatoryProcessUserRole.exists?(user:)
      end
    end

    def assembly_user_role?(user, assembly = nil)
      return false unless Decidim.module_installed?(:assemblies)

      if assembly.is_a?(Decidim::Assembly)
        Decidim::AssemblyUserRole.exists?(user:, assembly:)
      else
        Decidim::AssemblyUserRole.exists?(user:)
      end
    end

    def conference_user_role?(user, conference = nil)
      return false unless Decidim.module_installed?(:conferences)

      if conference.is_a?(Decidim::Conference)
        Decidim::ConferenceUserRole.exists?(user:, conference:)
      else
        Decidim::ConferenceUserRole.exists?(user:)
      end
    end
  end
end
