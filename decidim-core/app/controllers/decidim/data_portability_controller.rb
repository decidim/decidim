# frozen_string_literal: true

require "zip"

module Decidim
  # The controller to handle the user's download_my_data page.
  class DataPortabilityController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      enforce_permission_to :show, :user, current_user: current_user

      @account = form(AccountForm).from_model(current_user)
    end

    def export
      enforce_permission_to :export, :user, current_user: current_user
      name = current_user.name

      DataPortabilityExportJob.perform_later(current_user, name, export_format)

      flash[:notice] = t("decidim.admin.exports.notice")

      redirect_back(fallback_location: data_portability_path)
    end

    private

    def export_format
      "CSV"
    end
  end
end
