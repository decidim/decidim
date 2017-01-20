# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < ApplicationController
    helper_method :participatory_processes, :participatory_process, :promoted_processes, :current_participatory_process

    layout "layouts/decidim/participatory_process", only: [:show]

    def index
      authorize! :read, ParticipatoryProcess
    end

    def show
      authorize! :read, participatory_process
    end

    private

    def current_participatory_process
      participatory_process
    end

    def participatory_process
      @participatory_process ||= ParticipatoryProcess.find(params[:id])
    end

    def participatory_processes
      @participatory_processes ||= current_organization.participatory_processes.includes(:active_step).published
    end

    def promoted_processes
      @promoted_processes ||= participatory_processes.promoted
    end
  end
end
