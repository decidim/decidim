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
              activate_step(next_step)
            end
          else
            step_to_activate = steps.first
            if active_step != step_to_activate
              active_step&.update(active: false)
              activate_step(step_to_activate)
            end
          end
        end
      end

      private

      def activate_step(step)
        return step.update!(active: true) unless user_available?

        Decidim.traceability.perform_action!(
          :activate,
          step,
          system_user,
          details: {
            automatic_action: true
          }
        ) do
          step.update!(active: true)
        end
      end

      def system_user
        @system_user ||= Decidim::User.first
      end

      def user_available?
        system_user.present?
      end
    end
  end
end
