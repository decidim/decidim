# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        class CensusController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          before_action :show_instructions,
                        unless: :csv_census_active?

          include Decidim::Admin::WorkflowsBreadcrumb
          include Decidim::Paginable

          add_breadcrumb_item_from_menu :workflows_menu

          helper_method :csv_census_data

          def index
            enforce_permission_to :index, :authorization
          end

          def new
            @form = form(Admin::CensusForm).instance
          end

          def create
            @form = form(Admin::CensusForm).from_params(params)
            Admin::CreateCensusRecord.call(@form) do
              on(:ok) do
                flash[:notice] = t(".success")
                redirect_to census_records_path
              end

              on(:invalid) do
                flash.now[:alert] = t(".error")
                render :index
              end
            end
          end

          def edit
            @form = form(Admin::CensusForm).from_model(census_data)
          end

          def update
            @form = form(Admin::CensusForm).from_params(params)

            UpdateCensusRecord.call(@form, census_data) do
              on(:ok) do
                flash[:notice] = I18n.t("census.update.success", scope: "decidim.verifications.csv_census.admin")
                redirect_to census_records_path
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("census.update.invalid", scope: "decidim.verifications.csv_census.admin")
                render action: "edit"
              end
            end
          end

          def destroy
            Decidim::Commands::DestroyResource.call(census_data, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("census.destroy.success", scope: "decidim.verifications.csv_census.admin")
                redirect_to census_records_path
              end
            end
          end

          def new_import
            @form = form(CensusDataForm).from_params(params)
            @status = Status.new(current_organization)
          end

          def create_import
            enforce_permission_to :create, :authorization
            @form = form(CensusDataForm).from_params(params)
            @status = Status.new(current_organization)
            CreateCensusRecord.call(@form, current_organization) do
              on(:ok) do
                flash[:notice] = t(".success", count: @form.data.values.count, errors: @form.data.errors.count)
                redirect_to census_records_path
              end

              on(:invalid) do
                flash.now[:alert] = t(".error")
                render :index
              end
            end
          end

          private

          def census_data
            @census_data ||= CsvDatum.where(organization: current_organization).find(params[:id])
          end

          def csv_census_data
            @csv_census_data ||= CsvDatum.where(organization: current_organization).page(params[:page]).per(3)
          end

          def show_instructions
            enforce_permission_to :index, :authorization
            render :instructions
          end

          def csv_census_active?
            current_organization.available_authorizations.include?("csv_census")
          end
        end
      end
    end
  end
end
