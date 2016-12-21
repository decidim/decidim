# frozen_string_literal: true
module Decidim
  # Helpers related to the Participatory Process layout.
  module ParticipatoryProcessHelper
    # Public: Returns the dates for a step in a readable format like
    # "2016-01-01 - 2016-02-05".
    #
    # participatory_process_step - The step to format to
    #
    # Returns a String with the formatted dates.
    def participatory_process_step_dates(participatory_process_step)
      dates = [participatory_process_step.start_date, participatory_process_step.end_date]
      dates.map { |date| date ? localize(date.to_date, format: :default) : "?" }.join(" - ")
    end
  end
end
