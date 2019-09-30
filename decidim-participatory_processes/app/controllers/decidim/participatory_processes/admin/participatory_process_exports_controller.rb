# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      class ParticipatoryProcessExportsController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        helper_method :current_participatory_process, :current_participatory_space

        def create
          enforce_permission_to :export, :process, process: current_participatory_process
          
          ExportParticipatorySpaceJob.perform_later(current_user, current_participatory_process, "participatory_processes", default_format)

          flash[:notice] = t("decidim.admin.exports.notice")

          redirect_back(fallback_location: participatory_processes_path)
        end

        private

        def default_format
          "JSON"
        end
      end
    end
  end
end
