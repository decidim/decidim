# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ChangeActiveStepJob < ApplicationJob
      queue_as :default

      def perform
        Decidim::ParticipatoryProcesses::AutomateProcessesSteps.new.change_active_step
      end
    end
  end
end
