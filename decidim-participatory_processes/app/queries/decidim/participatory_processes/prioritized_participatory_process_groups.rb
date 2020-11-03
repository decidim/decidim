# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query orders processes by importance, prioritizing promoted processes
    # first, and closest to finalization date second.
    class PrioritizedParticipatoryProcessGroups < Rectify::Query
      def query
        Decidim::ParticipatoryProcessGroup.order(promoted: :desc)
      end
    end
  end
end
