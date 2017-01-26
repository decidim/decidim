# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < ApplicationController
    include NeedsParticipatoryProcess

    layout "layouts/decidim/participatory_process", only: [:show]

    helper_method :participatory_processes, :promoted_processes

    skip_after_action :verify_participatory_process, only: [:index]

    def index
      authorize! :read, ParticipatoryProcess
    end

    def show
      authorize! :read, current_participatory_process
    end

    private

    def participatory_processes
      @participatory_processes ||= current_organization.participatory_processes.includes(:active_step).published
    end

    def promoted_processes
      @promoted_processes ||= participatory_processes.promoted
    end
  end
end
