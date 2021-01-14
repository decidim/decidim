# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to create or update an election.
      class VotingsController < Admin::ApplicationController
        include Decidim::Votings::Admin::Filterable
        helper_method :votings, :voting

        def index
          enforce_permission_to :read, :votings
          @votings = filtered_collection
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
          enforce_permission_to :update, :voting, voting: current_voting
          @form = form(VotingForm).from_model(current_voting)
        end

        def update
          enforce_permission_to :update, :voting, voting: current_voting
          @form = form(VotingForm).from_params(params, voting_id: current_voting.id)
          
          UpdateVoting.call(current_voting, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.update.success", scope: "decidim.votings.admin")
              redirect_to votings_path
            end
          
            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.update.invalid", scope: "decidim.votings.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          # enforce_permission_to :delete, :voting, voting: current_voting
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
          enforce_permission_to :publish, :voting, voting: current_voting
          
          PublishVoting.call(current_voting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.publish.success", scope: "decidim.votings.admin")
              redirect_to votings_path
            end
          end
        end

        def unpublish
          enforce_permission_to :unpublish, :voting, voting: current_voting
          
          UnpublishVoting.call(current_voting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.unpublish.success", scope: "decidim.votings.admin")
              redirect_to votings_path
            end
          end
        end

        private

        def votings
          @votings ||= Decidim::Votings::Voting.where(organization: current_user.organization)
        end

        def collection
          @collection ||= OrganizationVotings.new(current_user.organization).query
        end

        def current_voting
          @current_voting ||= collection.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end
      end
    end
  end
end
