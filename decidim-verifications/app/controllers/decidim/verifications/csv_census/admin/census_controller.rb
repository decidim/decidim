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

          add_breadcrumb_item_from_menu :workflows_menu

          helper_method :csv_census_data

          def index
            enforce_permission_to :index, :authorization
            @status = Status.new(current_organization)
          end

          def new_import
            @form = form(CensusDataForm).from_params(params)
          end

          def create_import
            enforce_permission_to :create, :authorization
            @form = form(CensusDataForm).from_params(params)
            @status = Status.new(current_organization)
            CreateCensusData.call(@form, current_organization) do
              on(:ok) do
                flash[:notice] = t(".success", count: @form.data.values.count, errors: @form.data.errors.count)
                redirect_to census_path
              end

              on(:invalid) do
                flash[:alert] = t(".error")
                render :index
              end
            end
          end

          def edit; end

          def destroy
            Decidim::Commands::DestroyResource.call(csv_census_data, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("census.destroy.success", scope: "decidim.verifications.csv_census.admin")
                redirect_to census_path
              end
            end
          end

          def destroy_all
            enforce_permission_to :destroy, :authorization
            CsvDatum.clear(current_organization)

            redirect_to census_path, notice: t(".success")
          end

          private

          def csv_census_data
            @csv_census_data ||= CsvDatum.where(organization: current_organization)
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
