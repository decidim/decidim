# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory processes.
      #
      class ParticipatoryProcessCopiesController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        def new
          enforce_permission_to :create, :process
          @form = form(ParticipatoryProcessCopyForm).from_model(current_participatory_process)
        end

        def create
          enforce_permission_to :create, :process
          @form = form(ParticipatoryProcessCopyForm).from_params(params)

          CopyParticipatoryProcess.call(@form, current_participatory_process, current_user) do
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
      end
    end
  end
end
