# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalsMergesController < Admin::ApplicationController
        def create
          enforce_permission_to :merge, :proposals

          @form = form(Admin::ProposalsMergeForm).from_params(params)

          Admin::MergeProposals.call(@form) do
            on(:ok) do |_proposal|
              flash[:notice] = I18n.t("proposals_merges.create.success", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(@form.target_component).root_path
            end

            on(:invalid) do
              flash[:alert_html] = Decidim::ValidationErrorsPresenter.new(
                I18n.t("proposals_merges.create.invalid", scope: "decidim.proposals.admin"),
                @form
              ).message
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end
          end
        end
      end
    end
  end
end
