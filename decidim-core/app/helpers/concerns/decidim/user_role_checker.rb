# frozen_string_literal: true

module Decidim
  module UserRoleChecker
    # Shared behaviour for signed_in admins
    extend ActiveSupport::Concern

    private

    def user_has_any_role?(user, participatory_space = nil)
      return false unless user
      return true if user.admin
      return true if user.roles.any?
      return true if participatory_process_user_role?(user, participatory_space)
      return true if assembly_user_role?(user, participatory_space)
      return true if conference_user_role?(user, participatory_space)

      false
    end

    def participatory_process_user_role?(user, participatory_process = nil)
      return false unless Decidim.module_installed?(:participatory_processes)
      return false unless participatory_process.is_a?(Decidim::ParticipatoryProcess)

      Decidim::ParticipatoryProcessUserRole.exists?(user:, participatory_process:)
    end

    def assembly_user_role?(user, assembly = nil)
      return false unless Decidim.module_installed?(:assemblies)
      return false unless assembly.is_a?(Decidim::Assembly)

      Decidim::AssemblyUserRole.exists?(user:, assembly:)
    end

    def conference_user_role?(user, conference = nil)
      return false unless Decidim.module_installed?(:conferences)
      return false unless conference.is_a?(Decidim::Conference)

      Decidim::ConferenceUserRole.exists?(user:, conference:)
    end
  end
end
