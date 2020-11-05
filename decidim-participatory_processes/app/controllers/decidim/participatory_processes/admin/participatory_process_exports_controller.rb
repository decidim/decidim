# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      class ParticipatoryProcessExportsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::ParticipatorySpaceExport

        def exportable_space
          current_participatory_process
        end

        def manifest_name
          current_participatory_process.manifest.name.to_s
        end

        def after_export_path
          participatory_processes_path
        end
      end
    end
  end
end
