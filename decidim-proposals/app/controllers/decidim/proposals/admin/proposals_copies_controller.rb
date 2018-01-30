# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalsCopiesController < Admin::ApplicationController
        def new
          authorize! :manage, current_feature

          @form = form(Admin::ProposalsCopyForm).instance
        end

        def create
          authorize! :manage, current_feature

          @form = form(Admin::ProposalsCopyForm).from_params(params)

          authorize! :manage, @form.origin_feature

          Admin::CopyProposals.call(@form) do
            on(:ok) do |proposals|
              flash[:notice] = I18n.t("proposals_copies.create.success", scope: "decidim.proposals.admin", number: proposals.length)
              redirect_to EngineRouter.admin_proxy(current_feature).root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals_copies.create.invalid", scope: "decidim.proposals.admin")
              render action: "new"
            end
          end
        end
      end
    end
  end
end
