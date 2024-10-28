# frozen_string_literal: true

require "zip"

module Decidim
  # The controller to handle the user's download_my_data page.
  class DownloadYourDataController < Decidim::ApplicationController
    include Decidim::UserProfile
    include Decidim::Paginable

    def show
      enforce_permission_to(:show, :user, current_user:)

      @account = form(AccountForm).from_model(current_user)
      @exports = paginate(current_user.private_exports)
    end

    def export
      enforce_permission_to(:export, :user, current_user:)

      DownloadYourDataExportJob.perform_later(current_user)

      flash[:notice] = t("decidim.account.download_your_data_export.notice")
      redirect_back(fallback_location: download_your_data_path)
    end

    def download_file
      enforce_permission_to(:download, :user, current_user:)

      if private_export.expired?
        flash[:error] = t("decidim.account.download_your_data_export.export_expired")
        redirect_to download_your_data_path
      elsif private_export.file.attached?
        redirect_to Rails.application.routes.url_helpers.rails_blob_url(private_export.file.blob, only_path: true)
      else
        flash[:error] = t("decidim.account.download_your_data_export.file_no_exists")
        redirect_to download_your_data_path
      end
    end

    private

    def private_export
      @private_export ||= current_user.private_exports.find(params[:uuid])
    end
  end
end
