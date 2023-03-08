# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessGroupsController < Decidim::ParticipatoryProcesses::ApplicationController
      helper Decidim::SanitizeHelper
      helper_method :participatory_processes, :group, :active_content_blocks

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
        @group = Decidim::ParticipatoryProcessGroup.where(organization: current_organization).find(params[:id])
      end

      def active_content_blocks
        @active_content_blocks ||= if group.present?
                                     Decidim::ContentBlock.published.for_scope(
                                       :participatory_process_group_homepage,
                                       organization: current_organization
                                     ).where(
                                       scoped_resource_id: group.id
                                     )
                                   else
                                     Decidim::ContentBlock.none
                                   end
      end

      attr_reader :group
    end
  end
end
