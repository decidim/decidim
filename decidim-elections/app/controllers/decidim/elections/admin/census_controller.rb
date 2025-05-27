# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class CensusController < Admin::ApplicationController
        helper Decidim::Elections::Admin::ElectionsHelper

        helper_method :election, :status

        def edit
          enforce_permission_to(:update, :census, election:)

          @csv_census_form = form(CensusDataForm).instance
          @census_permissions_form = form(CensusPermissionsForm).instance
        end

        def update
          enforce_permission_to(:update, :census, election:)

          if params[:census_permissions]
            handle_census_permissions
          else
            handle_census_csv
          end
        end

        def destroy_all
          # enforce_permission_to(:destroy, :census, election:)
          Voter.clear(election)

          redirect_to election_census_path(election), notice: t("success", scope: "decidim.elections.admin.census.destroy")
        end

        private

        def election
          @election ||= Decidim::Elections::Election.where(component: current_component).find(params[:id])
        end

        def status
          @status = CsvCensus::Status.new(election)
        end

        def handle_census_permissions
          @form = form(CensusPermissionsForm).from_params(params[:census_permissions] || {})

          process_form(@form, CreateInternalCensus, success_message_for(@form), :edit)
        end

        def handle_census_csv
          @form = form(CensusDataForm).from_params(params)

          process_form(@form, CreateCensusData, success_message_for(@form, error_method: :errors), :edit)
        end

        def process_form(form, command_class, success_message, failure_template)
          command_class.call(form, election) do
            on(:ok) do
              flash[:notice] = success_message
              redirect_to election_census_path(election)
            end
            on(:invalid) do
              flash[:alert] = t(".error")
              render failure_template
            end
          end
        end

        def success_message_for(form, error_method: nil)
        end
      end
    end
  end
end
