# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render statistics in a Participatory Process.
    class ParticipatoryProcessStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      def participatory_process
        __getobj__.fetch(:participatory_process)
      end

      def participatory_space
        participatory_process
      end

      def participatory_space_sym
        :participatory_processes
      end
    end
  end
end
