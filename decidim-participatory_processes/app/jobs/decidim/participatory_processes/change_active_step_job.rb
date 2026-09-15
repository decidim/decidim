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
            if next_step.present?
              active_step.update(active: false)
              next_step.update(active: true)
              log!(next_step)
            end
          else
            step_to_activate = steps.first
            if active_step != step_to_activate
              active_step&.update(active: false)
              step_to_activate.update(active: true)
              log!(step_to_activate)
            end
          end
        end
      end

      private

      # Since the action is not done by any specific user, we instantiate a new user record
      # to which we explicitly set the id to equal to 0.
      # We could have changed the logs table to allow nil users, but that may have generated
      # other issues. Instead, we make the explicit assignment.
      def log!(step)
        Decidim::ActionLogger.log(
          :system_activate,
          Decidim::User.new(organization: step.organization, id: 0),
          step,
          nil,
          details: {
            automatic_action: true
          }
        )
      end
    end
  end
end
