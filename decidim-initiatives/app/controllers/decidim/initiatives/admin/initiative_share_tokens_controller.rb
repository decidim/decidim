# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # This controller allows sharing unpublished things.
      # It is targeted for customizations for sharing unpublished things that lives under
      # an initiative.
      class InitiativeShareTokensController < Decidim::Admin::ShareTokensController
        include InitiativeAdmin

        def resource
          current_initiative
        end
      end
    end
  end
end
