# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A class used to find the ParticipatoryProcesses from a ProcessGroup.
    class ParticipatoryProcessesByGroup < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      def self.for(process_group)
        new(process_group).query
      end

      # Initializes the class.
      def initialize(process_group)
        @process_group = process_group
      end

      def processes
        ParticipatoryProcess
      end

      def query
        return processes.all unless @process_group

        processes.where(participatory_process_group: @process_group)
      end
    end
  end
end
