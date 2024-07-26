# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This controller allows sharing unpublished things.
      # It is targeted for customizations for sharing unpublished things that lives under
      # an assembly.
      class AssemblyShareTokensController < Decidim::Admin::ShareTokensController
        include Concerns::AssemblyAdmin

        def resource
          current_assembly
        end
      end
    end
  end
end
