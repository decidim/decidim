# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This controller allows admins to manage moderations in an assembly.
      class ModerationsController < Decidim::Admin::ModerationsController
        include Concerns::AssemblyAdmin

        def current_participatory_space_manifest_name
          :assemblies
        end
      end
    end
  end
end
