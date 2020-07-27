# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Helpers related to the Participatory Process layout.
    module ParticipatoryProcessHelper
      include Decidim::FiltersHelper
      include Decidim::AttachmentsHelper
      include Decidim::IconHelper
      include Decidim::WidgetUrlsHelper
      include Decidim::SanitizeHelper
      include Decidim::ResourceReferenceHelper

      # Public: Returns the dates for a step in a readable format like
      # "2016-01-01 - 2016-02-05".
      #
      # participatory_process_step - The step to format to
      #
      # Returns a String with the formatted dates.
      def step_dates(participatory_process_step)
        dates = [participatory_process_step.start_date, participatory_process_step.end_date]
        dates.map { |date| date ? localize(date.to_date, format: :default) : "?" }.join(" - ")
      end

      # Public: Returns the path for the participatory process cta button
      #
      # Returns a String with path.
      def participatory_process_cta_path(process)
        return participatory_process_path(process) if process.active_step&.cta_path.blank?

        path, params = participatory_process_path(process).split("?")

        "#{path}/#{process.active_step.cta_path}" + (params.present? ? "?#{params}" : "")
      end
    end
  end
end
