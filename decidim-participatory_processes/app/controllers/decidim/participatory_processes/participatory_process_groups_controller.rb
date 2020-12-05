# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessGroupsController < Decidim::ParticipatoryProcesses::ApplicationController
      helper Decidim::SanitizeHelper
      helper_method :participatory_processes, :group

      before_action :set_group

      def index
        enforce_permission_to :list, :process_group
      end

      def show
        enforce_permission_to :read, :process_group, process_group: @group
      end

      private

      def participatory_processes
        @participatory_processes ||= if current_user
                                       return group.participatory_processes.published if current_user.admin

                                       group.participatory_processes.visible_for(current_user).published
                                     else
                                       group.participatory_processes.published.public_spaces
                                     end
      end

      def set_group
        @group = Decidim::ParticipatoryProcessGroup.find(params[:id])
      end

      attr_reader :group
    end
  end
end
