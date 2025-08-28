# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render statistics in a Participatory Process.
    class ParticipatoryProcessStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      private

      def scope_entity = __getobj__.fetch(:participatory_process)
    end
  end
end
