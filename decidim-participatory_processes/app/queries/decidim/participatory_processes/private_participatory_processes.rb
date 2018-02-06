# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes given a current_user.
    class PrivateParticipatoryProcesses < Rectify::Query
      def initialize(current_user)
        @current_user = current_user
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        if @current_user
          processes.private_spaces_user(@current_user.id)
        else
          processes.public_process
        end
      end
    end
  end
end
