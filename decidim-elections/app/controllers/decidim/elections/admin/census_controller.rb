# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class CensusController < Admin::ApplicationController
        helper Decidim::Elections::Admin::ElectionsHelper

        helper_method :election, :census_manifests

        before_action :set_census_manifest, only: [:edit, :update]

        def edit
          enforce_permission_to :update, :census, election: election

          @form = form(election.census.admin_form.constantize).from_params(election.census_settings, election: election) if election.census && election.census.admin_form.present?
        end

        def update
          enforce_permission_to :update, :census, election: election

          @form = form(election.census.admin_form.constantize).from_params(params, election: election) if election.census.admin_form.present?

          ProcessCensus.call(@form, election) do
            on(:ok) do
              flash[:notice] = t("decidim.elections.admin.census.update.success")
              redirect_to dashboard_page_election_path(election)
            end
            on(:invalid) do
              flash[:alert] = t("decidim.elections.admin.census.update.error")
              render :edit
            end
          end
        end

        private

        def set_census_manifest
          election.census_manifest = params[:manifest] if params[:manifest].present?
        end

        def census_manifests
          @census_manifests ||= Decidim::Elections.census_registry.manifests
        end

        def election
          @election ||= Decidim::Elections::Election.where(component: current_component).find(params[:id])
        end
      end
    end
  end
end
