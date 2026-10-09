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
            if next_phase.present?
              active_phase.update(active: false)
              next_phase.update(active: true)
            end
          else
            phase_to_activate = phases.first
            if active_phase != phase_to_activate
              active_phase&.update(active: false)
              phase_to_activate.update(active: true)
            end
          end
        end
      end
    end
  end
end
