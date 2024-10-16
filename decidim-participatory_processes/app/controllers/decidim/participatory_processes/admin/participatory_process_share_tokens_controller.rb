# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows admins to manage moderations in a participatory process.
      class ParticipatoryProcessShareTokensController < Decidim::Admin::ShareTokensController
        include Concerns::ParticipatoryProcessAdmin

        def resource
          current_participatory_process
        end
      end
    end
  end
end
