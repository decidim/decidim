# frozen_string_literal: true

module Decidim
  module Conferences
    # Helpers related to the Conferences layout.
    module ConferencesHelper
      include Decidim::ResourceHelper

      def participatory_processes_for_conference(conference_participatory_processes)
        html = ""
        html += %( <div class="section"> ).html_safe
        html += %( <h4 class="section-heading">#{t("conferences.show.related_participatory_processes", scope: "decidim")}</h4> ).html_safe
        html += %( <div class="row small-up-1 medium-up-2 card-grid"> ).html_safe
        conference_participatory_processes.each do |conference_participatory_process|
          html += render partial: "decidim/participatory_processes/participatory_process", locals: { participatory_process: conference_participatory_process }
        end
        html += %( </div> ).html_safe
        html += %( </div> ).html_safe

        html.html_safe
      end

      def assemblies_for_conference(conference_assemblies)
        html = ""
        html += %( <div class="section"> ).html_safe
        html += %( <h4 class="section-heading">#{t("conferences.show.related_assemblies", scope: "decidim")}</h4> ).html_safe
        html += %( <div class="row small-up-1 medium-up-2 card-grid"> ).html_safe
        conference_assemblies.each do |conference_assembly|
          html += render partial: "decidim/assemblies/assembly", locals: { assembly: conference_assembly }
        end
        html += %( </div> ).html_safe
        html += %( </div> ).html_safe

        html.html_safe
      end

      def consultations_for_conference(conference_consultations)
        html = ""
        html += %( <div class="section"> ).html_safe
        html += %( <h4 class="section-heading">#{t("conferences.show.related_consultations", scope: "decidim")}</h4> ).html_safe
        html += %( <div class="row small-up-1 medium-up-2 card-grid"> ).html_safe
        conference_consultations.each do |conference_consultation|
          html += %( #{card_for conference_consultation} ).html_safe
        end
        html += %( </div> ).html_safe
        html += %( </div> ).html_safe

        html.html_safe
      end
    end
  end
end
