# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes given a current_user.
    class VisibleParticipatoryProcesses < Rectify::Query
      def initialize(current_user)
        @current_user = current_user
      end

      def query
        Decidim::ParticipatoryProcess.visible_for(@current_user)
      end
    end
  end
end
