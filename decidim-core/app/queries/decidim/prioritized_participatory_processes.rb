# frozen_string_literal: true
module Decidim
  # This query orders processes by importance, prioritizing promoted processes
  # first, and closest to finalization date second.
  class PrioritizedParticipatoryProcesses < Rectify::Query
    def query
      Decidim::ParticipatoryProcess.order("promoted DESC").includes(:active_step).order("decidim_participatory_process_steps.end_date ASC")
    end
  end
end
