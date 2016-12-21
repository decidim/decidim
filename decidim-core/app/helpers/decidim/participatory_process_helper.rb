# frozen_string_literal: true
module Decidim
  module ParticipatoryProcessHelper
    def participatory_process_step_dates(participatory_process_step)
      dates = [participatory_process_step.start_date, participatory_process_step.end_date]
      dates.map { |date| date ? localize(date.to_date, format: :default) : "?" }.join(" - ")
    end
  end
end
