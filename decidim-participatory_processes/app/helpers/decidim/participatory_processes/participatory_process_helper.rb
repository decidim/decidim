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

      # Public: Builds the URL for the step Call To Action. Takes URL params
      # into account.
      #
      # process - a ParticipatoryProcess
      #
      # Returns a String that can be used as a URL.
      def step_cta_url(process)
        base_url, params = decidim_participatory_processes.participatory_process_path(process).split("?")

        if params.present?
          [base_url, "/", process.active_step.cta_path, "?", params].join("")
        else
          [base_url, "/", process.active_step.cta_path].join("")
        end
      end
    end
  end
end
