# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process publications.
      #
      # i18n-tasks-use t('decidim.admin.participatory_process_publications.create.error')
      # i18n-tasks-use t('decidim.admin.participatory_process_publications.create.success')
      # i18n-tasks-use t('decidim.admin.participatory_process_publications.destroy.error')
      # i18n-tasks-use t('decidim.admin.participatory_process_publications.destroy.success')
      class ParticipatoryProcessPublicationsController < Decidim::Admin::SpacePublicationsController
        include Concerns::ParticipatoryProcessAdmin

        private

        def enforce_permission_to_publish = enforce_permission_to(:publish, :process, process: current_participatory_process)

        def i18n_scope = "decidim.admin.participatory_process_publications"

        def fallback_location = participatory_processes_path
      end
    end
  end
end
