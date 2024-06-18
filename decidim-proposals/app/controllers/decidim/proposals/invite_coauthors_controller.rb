# frozen_string_literal: true

module Decidim
  module Proposals
    class InviteCoauthorsController < Decidim::Proposals::ApplicationController
      include Decidim::ControllerHelpers

      helper_method :proposal

      before_action :authenticate_user!

      # author invites coauthor
      def create
        enforce_permission_to :invite, :proposal_coauthor_invites, { proposal:, coauthor: }

        InviteCoauthor.call(proposal, coauthor) do
          on(:ok) do
            flash[:notice] = I18n.t("create.success", scope: "decidim.proposals.invite_coauthors", author_name: coauthor.name)
          end

          on(:invalid) do
            flash[:alert] = I18n.t("create.error", scope: "decidim.proposals.invite_coauthors")
          end
        end

        redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      # author cancels invitation
      def cancel
        enforce_permission_to :cancel, :proposal_coauthor_invites, { proposal:, coauthor: }

        CancelCoauthorship.call(proposal, coauthor) do
          on(:ok) do
            flash[:notice] = I18n.t("cancel.success", scope: "decidim.proposals.invite_coauthors", author_name: coauthor.name)
          end

          on(:invalid) do
            flash[:alert] = I18n.t("cancel.error", scope: "decidim.proposals.invite_coauthors")
          end
        end

        redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      # coauthor accepts invitation
      def update
        enforce_permission_to :accept, :proposal_coauthor_invites, { proposal:, coauthor: }

        AcceptCoauthorship.call(proposal, current_user) do
          on(:ok) do
            render json: { message: I18n.t("update.success", scope: "decidim.proposals.invite_coauthors") }
          end

          on(:invalid) do
            render json: { message: I18n.t("update.error", scope: "decidim.proposals.invite_coauthors") }, status: :unprocessable_entity
          end
        end
      end

      # coauthor declines invitation
      def destroy
        enforce_permission_to :decline, :proposal_coauthor_invites, { proposal:, coauthor: }

        RejectCoauthorship.call(proposal, current_user) do
          on(:ok) do
            render json: { message: I18n.t("destroy.success", scope: "decidim.proposals.invite_coauthors") }
          end

          on(:invalid) do
            render json: { message: I18n.t("destroy.error", scope: "decidim.proposals.invite_coauthors") }, status: :unprocessable_entity
          end
        end
      end

      private

      def coauthor
        @coauthor ||= Decidim::User.find(params[:id])
      end

      def proposal
        @proposal ||= Proposal.where(component: current_component).find(params[:proposal_id])
      end
    end
  end
end
