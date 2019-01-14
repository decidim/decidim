# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A controller that holds the logic to show ParticipatoryProcesses in a
    # public layout.
    class ParticipatoryProcessesController < Decidim::ParticipatoryProcesses::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: [:show, :statistics]

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::SanitizeHelper
      helper Decidim::ResourceReferenceHelper

      helper ParticipatoryProcessHelper

      helper_method :collection, :promoted_participatory_processes, :participatory_processes, :stats, :metrics, :filter
      helper_method :process_count_by_filter

      def index
        redirect_to "/404" if published_processes.none?

        enforce_permission_to :list, :process
        enforce_permission_to :list, :process_group
      end

      def show
        enforce_permission_to :read, :process, process: current_participatory_space
      end

      def statistics
        enforce_permission_to :read, :process, process: current_participatory_space
      end

      private

      def organization_participatory_processes
        @organization_participatory_processes ||= OrganizationParticipatoryProcesses.new(current_organization).query
      end

      def current_participatory_space
        return unless params["slug"]

        @current_participatory_space ||= organization_participatory_processes.where(slug: params["slug"]).or(
          organization_participatory_processes.where(id: params["slug"])
        ).first!
      end

      def published_processes
        @published_processes ||= OrganizationPublishedParticipatoryProcesses.new(current_organization, current_user)
      end

      def collection
        @collection ||= (participatory_processes.to_a + participatory_process_groups).flatten
      end

      def filtered_participatory_processes(filter_name = filter)
        OrganizationPrioritizedParticipatoryProcesses.new(current_organization, filter_name, current_user)
      end

      def participatory_processes
        @participatory_processes ||= filtered_participatory_processes(filter).query.where(decidim_participatory_process_group_id: nil)
      end

      def promoted_participatory_processes
        @promoted_participatory_processes ||= filtered_participatory_processes("all") | PromotedParticipatoryProcesses.new
      end

      def filtered_participatory_process_groups(filter_name = filter)
        OrganizationPrioritizedParticipatoryProcessGroups.new(current_organization, filter_name)
      end

      def participatory_process_groups
        @participatory_process_groups ||= filtered_participatory_process_groups(filter)
      end

      def stats
        @stats ||= ParticipatoryProcessStatsPresenter.new(participatory_process: current_participatory_space)
      end

      def metrics
        @metrics ||= ParticipatoryProcessMetricChartsPresenter.new(participatory_process: current_participatory_space)
      end

      def filter
        @filter = params[:filter] || default_filter
      end

      def default_filter
        return "active" if process_count_by_filter["active"].positive?
        return "upcoming" if process_count_by_filter["upcoming"].positive?
        return "past" if process_count_by_filter["past"].positive?
        "active"
      end

      def process_count_by_filter
        return @process_count_by_filter if @process_count_by_filter

        @process_count_by_filter = %w(active upcoming past).inject({}) do |collection_by_filter, filter_name|
          processes = filtered_participatory_processes(filter_name).query.where(decidim_participatory_process_group_id: nil)
          groups = filtered_participatory_process_groups(filter_name)
          collection_by_filter.merge(filter_name.to_s => processes.count + groups.count)
        end
        @process_count_by_filter["all"] = @process_count_by_filter.values.sum
        @process_count_by_filter
      end
    end
  end
end
