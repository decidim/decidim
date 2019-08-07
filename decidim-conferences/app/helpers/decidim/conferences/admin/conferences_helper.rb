# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This class contains helpers needed to format ParticipatoryProcesses
      # in order to use them in select forms for ConferenceParticipatoryProcess.
      #
      module ConferencesHelper
        # Public: A formatted collection of ParticipatoryProcesses to be used
        # in forms.
        def processes_selected
          if current_conference.present?
            @processes_selected ||= current_conference.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes").pluck(:id)
          end
        end

        def assemblies_selected
          @assemblies_selected ||= current_conference.linked_participatory_space_resources(:assemblies, "included_assemblies").pluck(:id) if current_conference.present?
        end

        def consultations_selected
          @consultations_selected ||= current_conference.linked_participatory_space_resources("Consultations", "included_consultations").pluck(:id) if current_conference.present?
        end
      end
    end
  end
end
