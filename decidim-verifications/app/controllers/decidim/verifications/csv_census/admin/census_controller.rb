# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        class CensusController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          before_action :show_instructions,
                        unless: :csv_census_active?

          def index
            enforce_permission_to :index, :authorization
            @form = form(CensusDataForm).instance
            @status = Status.new(current_organization)
          end

          def create
            enforce_permission_to :create, :authorization
            @form = form(CensusDataForm).from_params(params)
            CreateCensusData.call(@form, current_organization) do
              on(:ok) do
                flash[:notice] = t(".success", count: @form.data.values.count, errors: @form.data.errors.count)
              end

              on(:invalid) do
                flash[:alert] = t(".error")
              end
            end
            redirect_to census_path
          end

          def destroy_all
            enforce_permission_to :destroy, :authorization
            CsvDatum.clear(current_organization)

            redirect_to census_path, notice: t(".success")
          end

          private

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
