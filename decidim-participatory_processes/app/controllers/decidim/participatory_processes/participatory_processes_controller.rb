# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A controller that holds the logic to show ParticipatoryProcesses in a
    # public layout.
    class ParticipatoryProcessesController < Decidim::ApplicationController
      layout "layouts/decidim/participatory_process", only: [:show]

      before_action -> { extend NeedsParticipatoryProcess }, only: [:show]

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper

      helper ParticipatoryProcessHelper

      helper_method :collection, :promoted_participatory_processes, :participatory_processes, :stats, :filter

      def index
        redirect_to "/404" if published_processes.none?

        authorize! :read, ParticipatoryProcess
        authorize! :read, ParticipatoryProcessGroup
      end

      def show
        authorize! :read, current_participatory_process
      end

      private

      def published_processes
        @published_processes ||= OrganizationPublishedParticipatoryProcesses.new(current_organization)
      end

      def collection
        @collection ||= (participatory_processes.to_a + participatory_process_groups).flatten
      end

      def filtered_participatory_processes(filter = default_filter)
        OrganizationPrioritizedParticipatoryProcesses.new(current_organization, filter)
      end

      def participatory_processes
        @participatory_processes ||= filtered_participatory_processes(filter)
      end

      def promoted_participatory_processes
        @promoted_processes ||= filtered_participatory_processes | PromotedParticipatoryProcesses.new
      end

      def participatory_process_groups
        @process_groups ||= OrganizationPrioritizedParticipatoryProcessGroups.new(current_organization, filter)
      end

      def stats
        @stats ||= ParticipatoryProcessStatsPresenter.new(participatory_process: current_participatory_process)
      end

      def filter
        @filter = params[:filter] || default_filter
      end

      def default_filter
        "active"
      end
    end
  end
end
