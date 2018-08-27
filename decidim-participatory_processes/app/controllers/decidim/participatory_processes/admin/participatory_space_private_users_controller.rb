# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process privte users
      class ParticipatorySpacePrivateUsersController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::Concerns::HasPrivateUsers

        def after_destroy_path
          participatory_space_private_users_path(current_participatory_process)
        end

        def privatable_to
          current_participatory_process
        end
      end
    end
  end
end
