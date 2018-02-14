# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This class contains helpers needed to format Assemblies
      # in order to use them in select forms.
      #
      module AssemblyAreasForSelectHelper
        # Public: A formatted collection of Assemblies to be used
        # in forms.
        #
        # Returns an Array.

        def assembly_areas_for_select
          @assembly_areas_for_select ||= [
            [Decidim::Assembly::ASSEMBLY_AREAS[:territorial_areas][0],  Decidim::Assembly::ASSEMBLY_AREAS[:territorial_areas].collect {|v| [ t(".#{v}"), v ] }],
            [Decidim::Assembly::ASSEMBLY_AREAS[:sectorial_areas][0],  Decidim::Assembly::ASSEMBLY_AREAS[:sectorial_areas].collect {|v| [ t(".#{v}"), v ] }]
          ]
        end
      end
    end
  end
end
