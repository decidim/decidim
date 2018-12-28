# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        class CensusController < Decidim::Admin::ApplicationController
          include NeedsPermission

          layout "decidim/admin/users"

          before_action :show_instructions,
                        unless: :csv_census_active?

          def index
            enforce_permission_to :index, CsvDatum
            @status = Status.new(current_organization)
          end

          def create
            enforce_permission_to :create, CsvDatum
            if params[:file]
              data = CsvCensus::Data.new(params[:file].path)
              CsvDatum.insert_all(current_organization, data.values)
              RemoveDuplicatesJob.perform_later(current_organization)
              flash[:notice] = t(".success", count: data.values.count,
                                             errors: data.errors.count)
            end
            redirect_to census_path
          end

          def destroy_all
            enforce_permission_to :destroy, CsvDatum
            CsvDatum.clear(current_organization)

            redirect_to census_path, notice: t(".success")
          end

          private

          def show_instructions
            render :instructions
          end

          def csv_census_active?
            current_organization.available_authorizations.include?("csv_census")
          end

          def permission_class_chain
            [
              Decidim::Verifications::CsvCensus::Admin::Permissions,
              Decidim::Admin::Permissions,
              Decidim::Permissions
            ]
          end

          def permission_scope
            :admin
          end
        end
      end
    end
  end
end
