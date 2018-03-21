# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalsImportsController < Admin::ApplicationController
        def new
          authorize! :manage, current_component

          @form = form(Admin::ProposalsImportForm).instance
        end

        def create
          authorize! :manage, current_component

          @form = form(Admin::ProposalsImportForm).from_params(params)

          authorize! :manage, @form.origin_component

          Admin::ImportProposals.call(@form) do
            on(:ok) do |proposals|
              flash[:notice] = I18n.t("proposals_imports.create.success", scope: "decidim.proposals.admin", number: proposals.length)
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals_imports.create.invalid", scope: "decidim.proposals.admin")
              render action: "new"
            end
          end
        end
      end
    end
  end
end
