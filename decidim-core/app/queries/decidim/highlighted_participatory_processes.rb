# frozen_string_literal: true

module Decidim
  # This query adds some scopes so the processes are ready to be showed in a
  # public view.
  class HighlightedParticipatoryProcesses < Rectify::Query
    def query
      Decidim::ParticipatoryProcess.order("promoted DESC").includes(:active_step).order("decidim_participatory_process_steps.end_date ASC").limit(8)
    end
  end
end
