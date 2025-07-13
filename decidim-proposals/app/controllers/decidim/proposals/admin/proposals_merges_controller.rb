# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalsMergesController < Admin::ApplicationController
        layout false
        helper Decidim::Proposals::Admin::ProposalsHelper

        def new
          @form = form(Admin::ProposalsMergeForm).from_params(
            params.merge(attachment: form(AttachmentForm).from_params({}))
          )
        end

        def create
          enforce_permission_to :merge, :proposals

          @form = form(Admin::ProposalsMergeForm).from_params(params)

          Admin::MergeProposals.call(@form) do
            on(:ok) do |_proposal|
              flash[:notice] = I18n.t("proposals_merges.create.success", scope: "decidim.proposals.admin")
              render json: { redirect_url: EngineRouter.admin_proxy(@form.target_component).root_path }, status: :ok
            end

            on(:invalid) do
              flash.now[:alert_html] = Decidim::ValidationErrorsPresenter.new(
                I18n.t("proposals_merges.create.invalid", scope: "decidim.proposals.admin"),
                @form
              ).message
              render :new, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
