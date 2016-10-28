# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessPublicationsController < ApplicationController
      def create
        authorize ParticipatoryProcess

        PublishParticipatoryProcess.call(participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_participatory_process_publications.create.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_participatory_process_publications.create.error", scope: "decidim.admin")
          end

          redirect_back(fallback_location: participatory_processes_path)
        end
      end

      def destroy
        authorize participatory_process

        UnpublishParticipatoryProcess.call(participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_participatory_process_publications.destroy.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_participatory_process_publications.destroy.error", scope: "decidim.admin")
          end

          redirect_back(fallback_location: participatory_processes_path)
        end
      end

      private

      def participatory_process
        current_organization.participatory_processes.find(params[:participatory_process_id])
      end

      def policy_class(_record)
        Decidim::Admin::ParticipatoryProcessPolicy
      end
    end
  end
end
