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

      DataPortabilityExportJob.perform_later(current_user)

      flash[:notice] = t("decidim.account.data_portability_export.notice")
      redirect_back(fallback_location: data_portability_path)
    end

    def download_file
      enforce_permission_to :download, :user, current_user: current_user

      if current_user.data_portability_file.attached?
        redirect_to Rails.application.routes.url_helpers.rails_blob_url(current_user.data_portability_file.blob, only_path: true)
      else
        flash[:error] = t("decidim.account.data_portability_export.file_no_exists")
        redirect_to data_portability_path
      end
    end
  end
end
