# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessFiltersCell < Decidim::ViewModel
      def filter_link(filter)
        Decidim::ParticipatoryProcesses::Engine
          .routes
          .url_helpers
          .participatory_processes_path(filter: filter)
      end

      def filter
        options[:current_filter]
      end

      def title
        return active.to_s + " activos" if active > 0
        return upcoming.to_s + " futuros" if upcoming > 0
        (active + past + upcoming).to_s + " en total"
      end

      def active
        model["active"]
      end

      def past
        model["past"]
      end

      def upcoming
        model["upcoming"]
      end
    end
  end
end
