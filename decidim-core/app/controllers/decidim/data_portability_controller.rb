# frozen_string_literal: true

module Decidim
  # The controller to handle the user's download_my_data page.
  class DataPortabilityController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      authorize! :show, current_user
      @account = form(AccountForm).from_model(current_user)
    end

    def export
      authorize! :export, current_user
      name = "Test"

      DataPortabilityExportJob.perform_later(current_user, name, export_format)

      flash[:notice] = t("decidim.admin.exports.notice")

      redirect_back(fallback_location: data_portability_path)
    end

    private

    def export_format
      "CSV"
    end

    # def component
    #   @component ||= current_participatory_space.components.find(params[:component_id])
    # end

  end
end
