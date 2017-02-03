# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < ApplicationController
    include NeedsParticipatoryProcess

    layout "layouts/decidim/participatory_process", only: [:show]

    skip_after_action :verify_participatory_process, only: [:index]

    helper_method :participatory_processes, :promoted_participatory_processes

    def index
      authorize! :read, ParticipatoryProcess
    end

    def show
      authorize! :read, current_participatory_process
    end

    private

    def participatory_processes
      @processes ||= OrganizationParticipatoryProcesses.new(current_organization) | PublicParticipatoryProcesses.new
    end

    def promoted_participatory_processes
      @promoted_processes ||= participatory_processes | PromotedParticipatoryProcesses.new
    end
  end
end
