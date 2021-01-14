# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows the create or update an election.
      class VotingsController < Admin::ApplicationController
        helper_method :votings, :voting

        def index
          enforce_permission_to :read, :votings
        end

        def new
          enforce_permission_to :create, :voting
          @form = form(VotingForm).instance
        end

        def create
          enforce_permission_to :create, :voting
          @form = form(VotingForm).from_params(params)

          CreateVoting.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.create.success", scope: "decidim.votings.admin")
              redirect_to votings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.create.invalid", scope: "decidim.votings.admin")
              render action: "new"
            end
          end
        end

        def edit
          # enforce_permission_to :update, :voting, voting: voting
          # @form = form(VotingForm).from_model(voting)
        end

        def update
          # enforce_permission_to :update, :voting, voting: voting
          # @form = form(VotingForm).from_params(params)
          #
          # UpdateVoting.call(@form, voting) do
          #   on(:ok) do
          #     flash[:notice] = I18n.t("votings.update.success", scope: "decidim.votings.admin")
          #     redirect_to votings_path
          #   end
          #
          #   on(:invalid) do
          #     flash.now[:alert] = I18n.t("votings.update.invalid", scope: "decidim.votings.admin")
          #     render action: "edit"
          #   end
          # end
        end

        def destroy
          # enforce_permission_to :delete, :voting, voting: voting
          #
          # DestroyVoting.call(voting, current_user) do
          #   on(:ok) do
          #     flash[:notice] = I18n.t("votings.destroy.success", scope: "decidim.votings.admin")
          #   end
          #
          #   on(:invalid) do
          #     flash.now[:alert] = I18n.t("votings.destroy.invalid", scope: "decidim.votings.admin")
          #   end
          # end
          #
          # redirect_to votings_path
        end

        def publish
          # enforce_permission_to :publish, :voting, voting: voting
          #
          # PublishVoting.call(voting, current_user) do
          #   on(:ok) do
          #     flash[:notice] = I18n.t("admin.votings.publish.success", scope: "decidim.votings")
          #     redirect_to votings_path
          #   end
          # end
        end

        def unpublish
          # enforce_permission_to :unpublish, :voting, voting: voting
          #
          # UnpublishVoting.call(voting, current_user) do
          #   on(:ok) do
          #     flash[:notice] = I18n.t("admin.votings.unpublish.success", scope: "decidim.votings")
          #     redirect_to votings_path
          #   end
          # end
        end

        private

        def votings
          @votings ||= Decidim::Votings::Voting.where(organization: current_user.organization)
        end

        def voting
          @voting ||= votings.find_by(id: params[:id])
        end
      end
    end
  end
end
