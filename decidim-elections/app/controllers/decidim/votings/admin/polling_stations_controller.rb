# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to create or update a polling station.
      class PollingStationsController < Admin::ApplicationController
        include Decidim::PollingStations::Admin::Filterable
        helper Decidim::Votings::Admin::PollingOfficersPickerHelper
        include VotingAdmin

        helper_method :current_voting, :polling_station, :filtered_polling_stations

        def new
          enforce_permission_to :create, :polling_station, voting: current_voting
          @form = form(PollingStationForm).instance
        end

        def create
          enforce_permission_to :create, :polling_station, voting: current_voting
          @form = form(PollingStationForm).from_params(params, voting: current_voting)

          CreatePollingStation.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("polling_stations.create.success", scope: "decidim.votings.admin")
              redirect_to voting_polling_stations_path(current_voting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("polling_stations.create.invalid", scope: "decidim.votings.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :polling_station, voting: current_voting, polling_station: polling_station
          @form = form(PollingStationForm).from_model(polling_station, voting: current_voting)
        end

        def update
          enforce_permission_to :update, :polling_station, voting: current_voting, polling_station: polling_station
          @form = form(PollingStationForm).from_params(params, voting: current_voting)

          UpdatePollingStation.call(@form, polling_station) do
            on(:ok) do
              flash[:notice] = I18n.t("polling_stations.update.success", scope: "decidim.votings.admin")
              redirect_to voting_polling_stations_path(current_voting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("polling_stations.update.invalid", scope: "decidim.votings.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :polling_station, voting: current_voting, polling_station: polling_station

          DestroyPollingStation.call(polling_station, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("polling_stations.destroy.success", scope: "decidim.votings.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("polling_stations.destroy.invalid", scope: "decidim.votings.admin")
            end
          end

          redirect_to voting_polling_stations_path(current_voting)
        end

        private

        def polling_stations
          @polling_stations ||= current_voting.polling_stations
        end

        def polling_station
          @polling_station ||= polling_stations.find(params[:id])
        end

        def filtered_polling_stations
          filtered_collection.distinct
        end

        alias collection polling_stations
      end
    end
  end
end
