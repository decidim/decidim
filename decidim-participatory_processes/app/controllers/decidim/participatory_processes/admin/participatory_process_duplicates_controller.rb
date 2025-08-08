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
          @form = form(ParticipatoryProcessDuplicateForm).from_model(current_participatory_process)
        end

        def create
          enforce_permission_to :create, :process
          @form = form(ParticipatoryProcessDuplicateForm).from_params(params)

          DuplicateParticipatoryProcess.call(@form, current_participatory_process) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_processes_duplicates.create.success", scope: "decidim.admin")
              redirect_to participatory_processes_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes_duplicates.create.error", scope: "decidim.admin")
              render :new, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
