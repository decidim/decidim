# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A controller that holds the logic to show ParticipatoryProcessSteps in a
    # public layout.
    class ParticipatoryProcessStepsController < Decidim::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: :index

      def index; end

      private

      def organization_participatory_processes
        @organization_participatory_processes ||= OrganizationParticipatoryProcesses.new(current_organization).query
      end

      def current_participatory_space
        @current_participatory_space ||= organization_participatory_processes.find_by(slug: params[:participatory_process_slug])
      end
    end
  end
end
