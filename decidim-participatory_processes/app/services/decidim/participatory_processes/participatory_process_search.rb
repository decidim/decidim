# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Service that encapsulates all logic related to filtering participatory processes.
    class ParticipatoryProcessSearch < ParticipatorySpaceSearch
      def initialize(options = {})
        super(ParticipatoryProcess.all, options)
      end

      def search_date
        case date
        when "active"
          query.active.order(start_date: :desc)
        when "past"
          query.past.order(end_date: :desc)
        when "upcoming"
          query.upcoming.order(start_date: :asc)
        else # Assume 'all'
          current_zone = Time.zone.name
          query.order(Arel.sql("ABS(start_date - (CURRENT_DATE at time zone '#{current_zone}')::date)"))
        end
      end
    end
  end
end
