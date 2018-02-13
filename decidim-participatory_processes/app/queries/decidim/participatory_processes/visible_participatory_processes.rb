# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes given a current_user.
    class VisibleParticipatoryProcesses < Rectify::Query
      def initialize(current_user)
        @current_user = current_user
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        if @current_user
          processes.visible_participatory_processes_for(@current_user.id)
        else
          processes.non_private_spaces
        end
      end
    end
  end
end
