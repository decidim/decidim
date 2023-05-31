# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      module Moderations
        # This controller allows admins to manage moderation reports in a participatory process.
        class ReportsController < Decidim::Admin::Moderations::ReportsController
          include Concerns::ParticipatoryProcessAdmin

          def permissions_context
            super.merge(current_participatory_space:)
          end
        end
      end
    end
  end
end
