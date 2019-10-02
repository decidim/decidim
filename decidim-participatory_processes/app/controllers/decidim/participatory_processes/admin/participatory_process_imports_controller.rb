# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      class ParticipatoryProcessImportsController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        def new
          enforce_permission_to :import, :process
          @form = form(ParticipatoryProcessImportForm).instance
        end

        def create
          enforce_permission_to :import, :process
          @form = form(ParticipatoryProcessImportForm).from_params(params)

          ImportParticipatoryProcess.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_imports.create.success", scope: "decidim.admin")
              redirect_to participatory_processes_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_imports.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end
      end
    end
  end
end
