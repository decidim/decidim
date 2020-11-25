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

        def share
          privatable_to.share_tokens.create!(user: current_user, organization: current_organization)

          flash[:notice] = I18n.t("participatory_space_private_users.share.success", scope: "decidim.admin")
          redirect_to action: :index
        end

        def privatable_to
          current_participatory_process
        end
      end
    end
  end
end
