# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows importing participatory process private users
      # on participatory processes
      class ParticipatorySpacePrivateUsersCsvImportsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::Concerns::HasPrivateUsersCsvImport

        def after_import_path
          participatory_space_private_users_path(current_participatory_process)
        end

        def privatable_to
          current_participatory_process
        end
      end
    end
  end
end
