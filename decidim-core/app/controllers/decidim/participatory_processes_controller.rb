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
      @participatory_process ||=
        AvailableProcessesForUser.new(current_user, current_organization).query.where(id: params[:id]).first
    end

    def participatory_processes
      @participatory_processes ||= PublishedProcesses.new(current_organization)
    end

    def promoted_processes
      @promoted_processes ||= participatory_processes | PromotedProcesses.new
    end
  end
end
