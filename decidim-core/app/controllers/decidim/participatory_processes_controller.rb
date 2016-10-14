# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < ApplicationController
    helper_method :participatory_processes, :participatory_process, :hero_processes

    private

    def participatory_process
      @participatory_process ||= participatory_processes.find(params[:id])
    end

    def participatory_processes
      @participatory_processes ||= current_organization.participatory_processes
    end

    def hero_processes
      @hero_processes ||= participatory_processes.where(promoted: true)
    end
  end
end
