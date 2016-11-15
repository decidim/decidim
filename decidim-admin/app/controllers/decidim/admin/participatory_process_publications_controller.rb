# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessPublicationsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def create
        authorize! :publish, participatory_process

        PublishParticipatoryProcess.call(participatory_process) do
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
        authorize! :publish, participatory_process

        UnpublishParticipatoryProcess.call(participatory_process) do
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
