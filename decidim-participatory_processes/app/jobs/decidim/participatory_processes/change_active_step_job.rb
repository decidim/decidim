# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ChangeActiveStepJob < ApplicationJob
      queue_as :default

      def perform
        participatory_processes = Decidim::ParticipatoryProcess.published.where("start_date <= ? AND end_date >= ?", Time.zone.now.to_date, Time.zone.now.to_date)

        participatory_processes.each do |process|
          steps = Decidim::ParticipatoryProcessStep.unscoped
                                                   .where(decidim_participatory_process_id: process.id)
                                                   .where("start_date <= ? AND end_date >= ?", Time.zone.now, Time.zone.now).order("end_date ASC", :position)

          active_step = process.steps.find_by(active: true)
          if steps.empty? && active_step
            next_position = active_step.position + 1
            next_step = process.steps.where(start_date: ..Time.zone.now.to_date).find_by(position: next_position)
            activate_step(next_step, active_step) if next_step.present?
          else
            step_to_activate = steps.first
            activate_step(step_to_activate, active_step) if active_step != step_to_activate
          end
        end
      end

      private

      # Activates the given step and deactivates the previous one in a single
      # transaction, so the log is always consistent with the phase changes.
      def activate_step(step, previous_step)
        Decidim::ParticipatoryProcessStep.transaction do
          previous_step&.update!(active: false)
          step.update!(active: true)
          log(step)
        end
      end

      # Since the action is not done by any specific user, we log it as a system action.
      def log(step)
        Decidim::ActionLogger.log_system(:system_activate, step)
      end
    end
  end
end
