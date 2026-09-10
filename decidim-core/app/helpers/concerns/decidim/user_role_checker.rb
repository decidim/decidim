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
      return false if participatory_process && !participatory_process.is_a?(Decidim::ParticipatoryProcess)

      return Decidim::ParticipatoryProcessUserRole.exists?(user:) if broad_check

      return false if participatory_process.blank?

      Decidim::ParticipatoryProcessUserRole.exists?(user:, participatory_process:)
    end

    def assembly_user_role?(user, assembly = nil, broad_check: false)
      return false unless Decidim.module_installed?(:assemblies)
      return false if assembly && !assembly.is_a?(Decidim::Assembly)

      return Decidim::AssemblyUserRole.exists?(user:) if broad_check

      return false if assembly.blank?

      Decidim::AssemblyUserRole.exists?(user:, assembly:)
    end

    def conference_user_role?(user, conference = nil, broad_check: false)
      return false unless Decidim.module_installed?(:conferences)
      return false if conference && !conference.is_a?(Decidim::Conference)

      return Decidim::ConferenceUserRole.exists?(user:) if broad_check

      return false if conference.blank?

      Decidim::ConferenceUserRole.exists?(user:, conference:)
    end
  end
end
