# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      module Moderations
        # This controller allows admins to manage moderation reports in an conference.
        class ReportsController < Decidim::Admin::Moderations::ReportsController
          include InitiativeAdmin

          def permissions_context
            super.merge(current_participatory_space:)
          end
        end
      end
    end
  end
end
