# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly publications.
      #
      # i18n-tasks-use t('decidim.admin.assembly_publications.create.error')
      # i18n-tasks-use t('decidim.admin.assembly_publications.create.success')
      # i18n-tasks-use t('decidim.admin.assembly_publications.destroy.error')
      # i18n-tasks-use t('decidim.admin.assembly_publications.destroy.success')
      class AssemblyPublicationsController < Decidim::Admin::SpacePublicationsController
        include Concerns::AssemblyAdmin

        private

        def enforce_permission_to_publish = enforce_permission_to(:publish, :assembly, assembly: current_assembly)

        def i18n_scope = "decidim.admin.assembly_publications"

        def fallback_location = assemblies_path
      end
    end
  end
end
