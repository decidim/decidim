# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A controller that holds the logic to show ParticipatoryProcesses in a
    # public layout.
    class ParticipatoryProcessesController < Decidim::ParticipatoryProcesses::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: :show

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::SanitizeHelper
      helper Decidim::ResourceReferenceHelper

      helper ParticipatoryProcessHelper

      helper_method :collection, :promoted_participatory_processes, :participatory_processes, :stats, :filter

      def index
        redirect_to "/404" if published_processes.none?

        enforce_permission_to :list, :process
        enforce_permission_to :list, :process_group
      end

      def show
        check_current_user_can_visit_space
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

      def filtered_participatory_processes(filter = default_filter)
        OrganizationPrioritizedParticipatoryProcesses.new(current_organization, filter, current_user)
      end

      def participatory_processes
        @participatory_processes ||= filtered_participatory_processes(filter)
      end

      def promoted_participatory_processes
        @promoted_participatory_processes ||= filtered_participatory_processes | PromotedParticipatoryProcesses.new
      end

      def participatory_process_groups
        @participatory_process_groups ||= OrganizationPrioritizedParticipatoryProcessGroups.new(current_organization, filter)
      end

      def stats
        @stats ||= ParticipatoryProcessStatsPresenter.new(participatory_process: current_participatory_space)
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
