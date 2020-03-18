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

      def assemblies_for_participatory_process(participatory_process_assemblies)
        html = ""
        html += %( <div class="section"> ).html_safe
        html += %( <h4 class="section-heading">#{t("participatory_process.show.related_assemblies", scope: "decidim")}</h4> ).html_safe
        html += %( <div class="row small-up-1 medium-up-2 card-grid"> ).html_safe
        participatory_process_assemblies.each do |participatory_process_assembly|
          html += render partial: "decidim/assemblies/assembly", locals: { assembly: participatory_process_assembly }
        end
        html += %( </div> ).html_safe
        html += %( </div> ).html_safe

        html.html_safe
      end
    end
  end
end
