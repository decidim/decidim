# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Helper that provides a single method to give a class to a
    # ParticipatoryProcessStep depending on their date.
    module ParticipatoryProcessStepsHelper
      # Returns the class for the given step depending on their end_date.
      #
      # step - the given ParticipatoryProcessStep
      # past - a Boolean indicating if the step is past or not
      #
      # Returns a String.
      def step_class(step, past)
        status = past ? "" : "timeline__item--inactive"
        step.active? ? "timeline__item--current" : status
      end
    end
  end
end
