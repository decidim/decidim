# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes given a current_user.
    class VisibleParticipatoryProcessGroups < Rectify::Query
      def initialize(current_user)
        @current_user = current_user
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        if @current_user
          return groups if @current_user.admin?

          processes = processes.visible_for(@current_user.id)
        else
          processes = processes.public_spaces
        end

        groups.where(id: processes.pluck(:decidim_participatory_process_group_id))
      end

      def groups
        @groups ||= Decidim::ParticipatoryProcessGroup.all
      end
    end
  end
end
