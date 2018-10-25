# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalsSplitsController < Admin::ApplicationController
        def create
          enforce_permission_to :split, :proposals

          @form = form(Admin::ProposalsSplitForm).from_params(params)

          Admin::SplitProposals.call(@form) do
            on(:ok) do |_proposal|
              flash[:notice] = I18n.t("proposals_splits.create.success", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(@form.target_component).root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals_splits.create.invalid", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end
          end
        end
      end
    end
  end
end
