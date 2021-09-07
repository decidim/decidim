# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to create or update the ballot styles.
      class BallotStylesController < Admin::ApplicationController
        include VotingAdmin
        helper_method :ballot_styles, :current_voting, :voting_elections, :current_ballot_style

        def index
          enforce_permission_to :read, :ballot_styles, voting: current_voting
        end

        def new
          enforce_permission_to :create, :ballot_style, voting: current_voting
          @form = form(BallotStyleForm).instance
        end

        def create
          enforce_permission_to :create, :ballot_style, voting: current_voting

          @form = form(BallotStyleForm).from_params(params, voting: current_voting)

          CreateBallotStyle.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("create.success", scope: "decidim.votings.admin.ballot_styles")
              redirect_to voting_ballot_styles_path(current_voting)
            end

            on(:invalid) do
              flash[:alert] = t("create.error", scope: "decidim.votings.admin.ballot_styles")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :ballot_style, ballot_style: current_ballot_style, voting: current_voting
          @form = form(BallotStyleForm).from_model(current_ballot_style, voting: current_voting)
        end

        def update
          enforce_permission_to :update, :ballot_style, ballot_style: current_ballot_style, voting: current_voting
          @form = form(BallotStyleForm).from_params(params, voting: current_voting, ballot_style_id: current_ballot_style.id)

          UpdateBallotStyle.call(@form, current_ballot_style) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: "decidim.votings.admin.ballot_styles")
              redirect_to voting_ballot_styles_path(current_voting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.votings.admin.ballot_styles")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :ballot_style, ballot_style: current_ballot_style, voting: current_voting

          DestroyBallotStyle.call(current_ballot_style, current_user) do
            on(:ok) do
              flash[:notice] = t("destroy.success", scope: "decidim.votings.admin.ballot_styles")
            end

            on(:invalid) do
              flash[:alert] = t("destroy.invalid", scope: "decidim.votings.admin.ballot_styles")
            end
          end

          redirect_to voting_ballot_styles_path(current_voting)
        end

        private

        def current_ballot_style
          @current_ballot_style ||= BallotStyle.find(params[:id])
        end

        def ballot_styles
          current_voting.ballot_styles
        end

        def voting_elections
          election_components = current_voting.components.where(manifest_name: "elections")
          Decidim::Elections::Election.where(component: election_components)
        end
      end
    end
  end
end
