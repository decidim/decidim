# frozen_string_literal: true
module Decidim
  # Helper that provides a single method to give a class to a
  # ParticipatoryProcessStep depending on their date.
  module ParticipatoryProcessStepsHelper
    # Returns the class for the given step depending on their end_date.
    # step - the given ParticipatoryProcessStep
    #
    # Returns a String.
    def status_class_for(step)
      status = step.end_date > Time.current ? "timeline__item--inactive" : ""
      step.active? ? "timeline__item--current" : status
    end
  end
end
