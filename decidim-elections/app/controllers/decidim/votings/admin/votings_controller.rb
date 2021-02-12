# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to create or update a voting.
      class VotingsController < Admin::ApplicationController
        include Decidim::Votings::Admin::Filterable
        helper_method :votings, :current_voting, :current_participatory_space

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
          render layout: "decidim/admin/voting"
        end

        def update
          enforce_permission_to :update, :voting, voting: current_voting
          @form = form(VotingForm).from_params(params, voting_id: current_voting.id)

          UpdateVoting.call(current_voting, @form) do
            on(:ok) do |voting|
              flash[:notice] = I18n.t("votings.update.success", scope: "decidim.votings.admin")
              redirect_to edit_voting_path(voting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.update.invalid", scope: "decidim.votings.admin")
              render action: "edit"
            end
          end
        end

        def publish
          enforce_permission_to :publish, :voting, voting: current_voting

          PublishVoting.call(current_voting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.publish.success", scope: "decidim.votings.admin")
              redirect_to edit_voting_path(voting)
            end
          end
        end

        def unpublish
          enforce_permission_to :unpublish, :voting, voting: current_voting

          UnpublishVoting.call(current_voting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.unpublish.success", scope: "decidim.votings.admin")
              redirect_to edit_voting_path(voting)
            end
          end
        end

        def available_polling_officers
          respond_to do |format|
            format.json do
              if (term = params[:term].to_s).present?
                query = current_voting.available_polling_officers.joins(:user)
                query = if term.start_with?("@")
                          query.where("nickname ILIKE ?", "#{term.delete("@")}%")
                        else
                          query.where("name ILIKE ?", "%#{term}%").or(
                            query.where("email ILIKE ?", "%#{term}%")
                          )
                        end
                render json: query.all.collect { |u| { value: u.id, label: "#{u.name} (@#{u.nickname}) #{u.email}" } }
              else
                render json: []
              end
            end
          end
        end

        def polling_officers_picker
          render :polling_officers_picker, layout: false
        end

        private

        def votings
          @votings ||= OrganizationVotings.new(current_user.organization).query
        end

        def current_voting
          @current_voting ||= votings.where(slug: params[:slug]).or(
            votings.where(id: params[:slug])
          ).first
        end

        alias collection votings
        alias current_participatory_space current_voting
      end
    end
  end
end
