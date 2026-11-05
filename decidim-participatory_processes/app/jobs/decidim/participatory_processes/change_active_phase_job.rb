# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ChangeActivePhaseJob < ApplicationJob
      queue_as :default

      def perform
        participatory_processes = Decidim::ParticipatoryProcess.published.where("start_date <= ? AND end_date >= ?", Time.zone.now.to_date, Time.zone.now.to_date)

        participatory_processes.each do |process|
          phases = Decidim::ParticipatoryProcessPhase.unscoped
                                                     .where(decidim_participatory_process_id: process.id)
                                                     .where("start_date <= ? AND end_date >= ?", Time.zone.now, Time.zone.now).order("end_date ASC", :position)

          active_phase = process.phases.find_by(active: true)
          if phases.empty? && active_phase
            next_position = active_phase.position + 1
            next_phase = process.phases.where(start_date: ..Time.zone.now.to_date).find_by(position: next_position)
            activate_phase(next_phase, active_phase) if next_phase.present?
          else
            phase_to_activate = phases.first
            activate_phase(phase_to_activate, active_phase) if active_phase != phase_to_activate
          end
        end
      end

      private

      # Activates the given phase and deactivates the previous one in a single
      # transaction, so the log is always consistent with the phase changes.
      # The target phase is locked and reloaded inside the transaction so
      # concurrent executions cannot log the same phase change twice: the first
      # one performs the transition, the rest see the phase as already active.
      def activate_phase(phase, previous_phase)
        Decidim::ParticipatoryProcessPhase.transaction do
          phase.lock!

          next if phase.active?

          previous_phase&.update!(active: false)
          phase.update!(active: true)
          log(phase)
        end
      end

      # Since the action is not done by any specific user, we log it as a system action.
      def log(phase)
        Decidim::ActionLogger.log_system(:system_activate, phase)
      end
    end
  end
end
