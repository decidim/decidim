# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        class CensusRecordsController < Decidim::Admin::ApplicationController
          layout false

          helper_method :csv_census_data

          def new_record
            @form = form(Admin::CensusForm).instance
          end

          def create_record
            @form = form(Admin::CensusForm).from_params(params)
            Admin::CreateCensusRecord.call(@form) do
              on(:ok) do
                flash[:notice] = I18n.t("census_records.create_record.success", scope: "decidim.verifications.csv_census.admin")
                render json: { redirect_url: census_logs_path }, status: :ok
              end

              on(:invalid) do
                render :new_record, status: :unprocessable_entity
              end
            end
          end

          def edit_record
            @form = form(Admin::CensusForm).from_model(census_data)
          end

          def update_record
            @form = form(Admin::CensusForm).from_params(params)

            Admin::UpdateCensusRecord.call(@form, census_data) do
              on(:ok) do
                flash[:notice] = I18n.t("census_records.update_record.success", scope: "decidim.verifications.csv_census.admin")
                render json: { redirect_url: census_logs_path }, status: :ok
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("census_records.update_record.invalid", scope: "decidim.verifications.csv_census.admin")
                render action: "edit_record", status: :unprocessable_entity
              end
            end
          end

          private

          def census_data
            @census_data ||= CsvDatum.where(organization: current_organization).find_by(id: params[:id])
          end

          def csv_census_data
            @csv_census_data ||= CsvDatum.where(organization: current_organization)
          end
        end
      end
    end
  end
end
