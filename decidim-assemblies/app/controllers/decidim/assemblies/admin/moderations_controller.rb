# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This controller allows admins to manage moderations in an assembly.
      class ModerationsController < Decidim::Admin::ModerationsController
        include Concerns::AssemblyAdmin

        protected

        def allowed_params
          super.push(:assembly_slug)
        end
      end
    end
  end
end
