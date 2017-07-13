# frozen_string_literal: true

module Decidim
  # A controller that holds the logic to show ParticipatoryProcesses in a
  # public layout.
  class ParticipatoryProcessesController < Decidim::ApplicationController
    layout "layouts/decidim/participatory_process", only: [:show]

    before_action -> { extend NeedsParticipatoryProcess }, only: [:show]

    helper Decidim::AttachmentsHelper
    helper Decidim::ParticipatoryProcessHelper
    helper Decidim::IconHelper
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
