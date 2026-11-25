# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Helper that provides a single method to give a class to a
    # ParticipatoryProcessPhase depending on their date.
    module ParticipatoryProcessPhasesHelper
      # Returns the class for the given phase depending on their end_date.
      #
      # phase - the given ParticipatoryProcessPhase
      # past - a Boolean indicating if the phase is past or not
      #
      # Returns a String.
      def phase_class(phase, past)
        status = past ? "" : "timeline__item--inactive"
        phase.active? ? "timeline__item--current" : status
      end
    end
  end
end
