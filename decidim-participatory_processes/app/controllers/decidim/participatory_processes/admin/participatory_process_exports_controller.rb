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

        def after_export_path
          participatory_processes_path
        end
      end
    end
  end
end
