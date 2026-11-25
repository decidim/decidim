# frozen_string_literal: true

module Decidim
  module UserRoleChecker
    # Shared behaviour for signed_in admins
    extend ActiveSupport::Concern

    private

    def user_has_any_role?(user, participatory_space = nil, broad_check: false)
      return false unless user

      @user_has_any_role_cache ||= {}
      cache_key = [user.id, participatory_space&.class&.name, participatory_space&.id, broad_check]
      return @user_has_any_role_cache[cache_key] if @user_has_any_role_cache.has_key?(cache_key)

      @user_has_any_role_cache[cache_key] = global_user_role?(user) || space_user_role?(user, participatory_space, broad_check:)
    end

    def global_user_role?(user)
      user.admin || user.roles.any?
    end

    def space_user_role?(user, participatory_space, broad_check: false)
      return participatory_process_user_role?(user, participatory_space, broad_check:) if participatory_process_space?(participatory_space)
      return assembly_user_role?(user, participatory_space, broad_check:) if assembly_space?(participatory_space)
      return conference_user_role?(user, participatory_space, broad_check:) if conference_space?(participatory_space)
      return false unless broad_check

      participatory_process_user_role?(user, nil, broad_check: true) ||
        assembly_user_role?(user, nil, broad_check: true) ||
        conference_user_role?(user, nil, broad_check: true)
    end

    def participatory_process_space?(participatory_space)
      Decidim.module_installed?(:participatory_processes) && participatory_space.is_a?(Decidim::ParticipatoryProcess)
    end

    def assembly_space?(participatory_space)
      Decidim.module_installed?(:assemblies) && participatory_space.is_a?(Decidim::Assembly)
    end

    def conference_space?(participatory_space)
      Decidim.module_installed?(:conferences) && participatory_space.is_a?(Decidim::Conference)
    end

    # A role in the given space always counts, even when that space is trashed, because that is
    # what allows the space admins to reach their own trashed space (and restore it). The broad
    # check only considers roles attached to spaces that are not trashed, so a role in a trashed
    # space does not grant access to any other space.
    def participatory_process_user_role?(user, participatory_process = nil, broad_check: false)
      return false unless Decidim.module_installed?(:participatory_processes)
      return false unless participatory_process.nil? || participatory_process.is_a?(Decidim::ParticipatoryProcess)

      return true if participatory_process && Decidim::ParticipatoryProcessUserRole.exists?(user:, participatory_process:)
      return false unless broad_check

      Decidim::ParticipatoryProcessUserRole.exists?(user:, participatory_process: Decidim::ParticipatoryProcess.where(deleted_at: nil))
    end

    def assembly_user_role?(user, assembly = nil, broad_check: false)
      return false unless Decidim.module_installed?(:assemblies)
      return false unless assembly.nil? || assembly.is_a?(Decidim::Assembly)

      return true if assembly && Decidim::AssemblyUserRole.exists?(user:, assembly:)
      return false unless broad_check

      Decidim::AssemblyUserRole.exists?(user:, assembly: Decidim::Assembly.where(deleted_at: nil))
    end

    def conference_user_role?(user, conference = nil, broad_check: false)
      return false unless Decidim.module_installed?(:conferences)
      return false unless conference.nil? || conference.is_a?(Decidim::Conference)

      return true if conference && Decidim::ConferenceUserRole.exists?(user:, conference:)
      return false unless broad_check

      Decidim::ConferenceUserRole.exists?(user:, conference: Decidim::Conference.where(deleted_at: nil))
    end
  end
end
