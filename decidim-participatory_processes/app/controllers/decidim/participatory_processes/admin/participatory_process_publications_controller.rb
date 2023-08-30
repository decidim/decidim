# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process publications.
      #
      class ParticipatoryProcessPublicationsController < Decidim::Admin::SpacePublicationsController
        include Concerns::ParticipatoryProcessAdmin

        private

        def current_participatory_space = current_participatory_process

        def enforce_permission_to_publish = enforce_permission_to(:publish, :process, process: current_participatory_process)

        def publish_command = PublishParticipatoryProcess

        def unpublish_command = UnpublishParticipatoryProcess

        def i18n_scope = "decidim.admin.participatory_process_publications"

        def fallback_location = participatory_processes_path
      end
    end
  end
end
