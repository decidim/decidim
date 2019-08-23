# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows importing assembly private users
      # on assembies
      class ParticipatorySpacePrivateUsersCsvImportsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::Concerns::HasPrivateUsersCsvImport

        def after_import_path
          participatory_space_private_users_path(current_assembly)
        end

        def privatable_to
          current_participatory_process
        end
      end
    end
  end
end
