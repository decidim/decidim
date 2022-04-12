# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This service change the processes steps automatically.
    class AutomateProcessesSteps
      def initialize
        @participatory_processes = Decidim::ParticipatoryProcess.published.where("start_date <= ? AND end_date >= ?", Time.zone.now.to_date, Time.zone.now.to_date)
      end

      def change_active_step
        @participatory_processes.each do |process|
          steps = process.steps.where("start_date <= ?", Time.zone.now).order("start_date ASC")

          active_step = process.steps.find_by(active: true)
          step_to_activate = steps.last
          if active_step != step_to_activate
            active_step&.update(active: false)
            step_to_activate.update(active: true)
          end
        end
      end
    end
  end
end
