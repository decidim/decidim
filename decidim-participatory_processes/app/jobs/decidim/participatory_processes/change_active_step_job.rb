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

          if steps.empty?
            process.steps.find_by(active: true).update(active: false)
            process.steps.order("end_date ASC", :position).last.update(active: true)
            next
          end

          active_step = process.steps.find_by(active: true)
          step_to_activate = steps.first
          if active_step != step_to_activate
            active_step&.update(active: false)
            step_to_activate.update(active: true)
          end
        end
      end
    end
  end
end
