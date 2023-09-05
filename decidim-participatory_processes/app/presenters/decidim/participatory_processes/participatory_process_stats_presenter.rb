# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render statistics in a Participatory Process.
    class ParticipatoryProcessStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      private

      def participatory_space = __getobj__.fetch(:participatory_process)

      def participatory_space_sym = :participatory_processes
    end
  end
end
