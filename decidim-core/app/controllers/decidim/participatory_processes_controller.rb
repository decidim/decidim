# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < ApplicationController
    helper_method :participatory_processes, :participatory_process, :promoted_processes

    def show
      raise ActionController::RoutingError, "Not Found" unless participatory_process
    end

    private

    def participatory_process
      @participatory_process ||= if current_user && current_user.role?(:admin)
                                   all_processes
                                 else
                                   participatory_processes
                                 end.where(id: params[:id]).first
    end

    def participatory_processes
      @participatory_processes ||= all_processes.published
    end

    def all_processes
      @all_processes ||= current_organization.participatory_processes.includes(:active_step)
    end

    def promoted_processes
      @promoted_processes ||= participatory_processes.where(promoted: true)
    end
  end
end
