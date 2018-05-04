# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process publications.
      #
      class ParticipatoryProcessPublicationsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        def create
          enforce_permission_to :publish, :process, process: current_participatory_process

          PublishParticipatoryProcess.call(current_participatory_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_publications.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_publications.create.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: participatory_processes_path)
          end
        end

        def destroy
          enforce_permission_to :publish, :process, process: current_participatory_process

          UnpublishParticipatoryProcess.call(current_participatory_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_publications.destroy.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_publications.destroy.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: participatory_processes_path)
          end
        end
      end
    end
  end
end
