# frozen_string_literal: true

require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < ApplicationController
    include NeedsParticipatoryProcess

    layout "layouts/decidim/participatory_process", only: [:show]

    skip_after_action :verify_participatory_process, only: [:index]

    helper Decidim::AttachmentsHelper
    helper Decidim::ParticipatoryProcessHelper
    helper Decidim::WidgetUrlsHelper
    helper_method :collection, :promoted_participatory_processes, :participatory_processes

    def index
      authorize! :read, ParticipatoryProcess
      authorize! :read, ParticipatoryProcessGroup
    end

    def show
      authorize! :read, current_participatory_process
    end

    private

    def collection
      @collection ||= (participatory_processes.to_a + participatory_process_groups).flatten
    end

    def participatory_processes
      @participatory_processes ||= OrganizationPrioritizedParticipatoryProcesses.new(current_organization)
    end

    def promoted_participatory_processes
      @promoted_processes ||= participatory_processes | PromotedParticipatoryProcesses.new
    end

    def participatory_process_groups
      @process_groups ||= Decidim::ParticipatoryProcessGroup.where(organization: current_organization)
    end
  end
end
