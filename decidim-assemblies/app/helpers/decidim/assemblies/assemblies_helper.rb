# frozen_string_literal: true

module Decidim
  module Assemblies
    module AssembliesHelper
      def participatory_processes_for_assembly(assembly_participatory_processes)
        html = ""
        html += %( <div class="section"> ).html_safe
        html += %( <h4 class="section-heading">#{t("assemblies.show.related_participatory_processes", scope: "decidim")}</h4> ).html_safe
        html += %( <div class="row small-up-1 medium-up-2 card-grid"> ).html_safe
        assembly_participatory_processes.each do |assembly_participatory_process|
          html += render partial: "decidim/participatory_processes/participatory_process", locals: { participatory_process: assembly_participatory_process }
        end
        html += %( </div> ).html_safe
        html += %( </div> ).html_safe
        html.html_safe
      end
    end
  end
end
