# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This service change the processes steps automatically.
    class AutomateProcessesSteps
      def initialize
        @participatory_processes = Decidim::ParticipatoryProcess.where.not(published_at: nil).where(start_date: ..Time.zone.now, end_date: Time.zone.now..)
      end

      def change_active_step
        @participatory_processes.each do |process|
          steps = process.steps.where(start_date: ..Time.zone.now)
          active_step = steps.select(&:active).first

          steps_candidates = select_steps_candidates(steps, active_step)

          next if active_step.blank?
          next if steps_candidates.blank?

          step_to_active = steps_candidates.min_by { |s| s[:time_to_next_start_date] }[:step]

          active_step.update!(active: false)
          step_to_active.update!(active: true)
        end
      end

      private

      def select_steps_candidates(steps, active_step)
        candidates = []
        steps.each do |stp|
          if active_step.nil?
            stp.update!(active: true)
            next
          end

          next if stp == active_step || stp.end_date <= Time.zone.now
          next if stp.start_date <= active_step.start_date

          candidates.append({ step: stp, time_to_next_start_date: stp.start_date - Time.zone.now })
        end

        candidates
      end
    end
  end
end
