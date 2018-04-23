# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessGroupsController < Decidim::ParticipatoryProcesses::ApplicationController
      helper Decidim::SanitizeHelper
      helper_method :participatory_processes, :group, :collection

      before_action :set_group

      def show
        authorize! :read, ParticipatoryProcessGroup
      end

      private

      def participatory_processes
        @participatory_processes ||= if current_user
                                       group.participatory_processes.visible_for(current_user.id).published
                                     else
                                       group.participatory_processes.published
                                     end
      end
      alias collection participatory_processes

      def set_group
        @group = Decidim::ParticipatoryProcessGroup.find(params[:id])
      end

      attr_reader :group

      def current_participatory_space_manifest_name
        :participatory_processes
      end
    end
  end
end
