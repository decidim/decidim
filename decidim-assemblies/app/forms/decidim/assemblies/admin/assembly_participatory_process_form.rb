# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assemblies from the admin
      # dashboard.
      #
      class AssemblyParticipatoryProcessForm < Form
        attribute :participatory_process_id, Integer

        def participatory_process
          @participatory_process ||= Decidim::ParticipatoryProcess.where(id: participatory_process_id).first
        end
      end
    end
  end
end
