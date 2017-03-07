# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < ApplicationController
    include NeedsParticipatoryProcess

    layout "layouts/decidim/participatory_process", only: [:show]

    skip_after_action :verify_participatory_process, only: [:index]

    helper_method :collection, :promoted_participatory_processes

    def index
      authorize! :read, ParticipatoryProcess
      authorize! :read, ParticipatoryProcessGroup
    end

    def show
      authorize! :read, current_participatory_process
    end

    private

    def collection
      @collection ||= PublicProcesses.new(current_organization).collection
    end

    def promoted_participatory_processes
      @promoted_processes ||= ParticipatoryProcess.where(organization: current_organization).promoted
    end
  end
end
