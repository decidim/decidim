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
          return processes if @current_user.admin
          processes.visible_for(@current_user.id)
        else
          processes.public_spaces
        end
      end
    end
  end
end
