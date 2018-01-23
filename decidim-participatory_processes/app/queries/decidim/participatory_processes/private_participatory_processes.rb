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
          processes.joins("LEFT JOIN decidim_participatory_process_users ON
            decidim_participatory_process_users.decidim_participatory_process_id =
            decidim_participatory_processes.id")
            .where("(private_process = true and decidim_participatory_process_users.decidim_user_id
              = #{ @current_user.id}) or private_process = false")
        else
          processes.public_process
        end
        # processes = Decidim::ParticipatoryProcess.all
        #
        # case @filter
        # when "all"
        #   processes
        # when "past"
        #   processes.past
        # when "upcoming"
        #   processes.upcoming
        # else
        #   processes.active
        # end
      end
    end
  end
end
