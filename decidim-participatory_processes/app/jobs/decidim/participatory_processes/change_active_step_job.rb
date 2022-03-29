# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # rubocop:disable Rails/ApplicationJob
    class ChangeActiveStepJob < ActiveJob::Base
      queue_as :default

      def perform
        Decidim::ParticipatoryProcesses::AutomateProcessesSteps.new.change_active_step
      end
    end
    # rubocop:enable Rails/ApplicationJob
  end
end
