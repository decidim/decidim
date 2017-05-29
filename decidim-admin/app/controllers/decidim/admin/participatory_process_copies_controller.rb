# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing participatory processes.
    #
    class ParticipatoryProcessCopiesController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      helper_method :participatory_process

      def new
        authorize! :new, Decidim::ParticipatoryProcess
        @form = form(ParticipatoryProcessCopyForm).from_model(participatory_process)
      end

      def create
        authorize! :create, Decidim::ParticipatoryProcess
        @form = form(ParticipatoryProcessCopyForm).from_params(params)

        CopyParticipatoryProcess.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_processes_copies.create.success", scope: "decidim.admin")
            redirect_to participatory_processes_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_processes_copies.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      private

      def collection
        @collection ||= ManageableParticipatoryProcessesForUser.for(current_user)
      end

      def participatory_process
        @participatory_process ||= collection.find(params[:participatory_process_id])
      end
    end
  end
end
