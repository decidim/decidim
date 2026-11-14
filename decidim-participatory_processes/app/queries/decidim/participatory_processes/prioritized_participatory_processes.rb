# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query orders processes by importance, prioritizing promoted processes
    # first, and closest to finalization date second.
    class PrioritizedParticipatoryProcesses < Decidim::Query
      def query
        Decidim::ParticipatoryProcess.order(promoted: :desc).includes(:active_phase).order("decidim_participatory_process_phases.end_date ASC")
      end
    end
  end
end
