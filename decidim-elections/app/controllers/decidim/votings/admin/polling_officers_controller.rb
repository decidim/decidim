# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to create or update a polling officer.
      class PollingOfficersController < Admin::ApplicationController
        include Decidim::PollingOfficers::Admin::Filterable
        include VotingAdmin

        helper_method :current_voting, :polling_officers, :polling_officer, :filtered_polling_officers

        def new
          enforce_permission_to :create, :polling_officer, voting: current_voting
          @form = form(PollingOfficerForm).instance
        end

        def create
          enforce_permission_to :create, :polling_officer, voting: current_voting
          @form = form(PollingOfficerForm).from_params(params, voting: current_voting)

          CreatePollingOfficer.call(@form, current_user, current_voting) do
            on(:ok) do
              flash[:notice] = I18n.t("polling_officers.create.success", scope: "decidim.votings.admin")
              redirect_to voting_polling_officers_path(current_voting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("polling_officers.create.invalid", scope: "decidim.votings.admin")
              render action: "new"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :polling_officer, voting: current_voting, polling_officer: polling_officer

          DestroyPollingOfficer.call(polling_officer, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("polling_officers.destroy.success", scope: "decidim.votings.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("polling_officers.destroy.invalid", scope: "decidim.votings.admin")
            end
          end

          redirect_to voting_polling_officers_path(current_voting)
        end

        private

        def polling_officers
          @polling_officers ||= current_voting.polling_officers
        end

        def polling_officer
          @polling_officer ||= polling_officers.find(params[:id])
        end

        alias collection polling_officers
        alias filtered_polling_officers filtered_collection
      end
    end
  end
end
