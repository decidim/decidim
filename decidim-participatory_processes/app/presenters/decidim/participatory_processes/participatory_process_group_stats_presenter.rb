# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render statistics in a Participatory Process Group
    class ParticipatoryProcessGroupStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      private

      def participatory_space = __getobj__.fetch(:participatory_process_group)

      def participatory_space_sym = :participatory_process_group

      def participatory_processes
        @participatory_processes ||= participatory_space.participatory_processes
      end

      def published_components
        @published_components ||= Component.where(participatory_space: participatory_processes).published
      end
    end
  end
end
