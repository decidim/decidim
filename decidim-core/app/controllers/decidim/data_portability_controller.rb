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

      DataPortabilityExportJob.perform_later(current_user, export_format)

      flash[:notice] = t("decidim.account.data_portability_export.notice")

      redirect_back(fallback_location: data_portability_path)
    end

    def download_file
      enforce_permission_to :download, :user, current_user: current_user

      if params[:token].present?
        file_reader = Decidim::DataPortabilityFileReader.new(current_user, params[:token])
        if file_reader.valid_token?
          file = File.open(file_reader.file_path)
          if File.exist?(file)
            send_file file, type: "application/zip", disposition: "attachment"
          else
            flash[:error] = t("decidim.account.data_portability_export.file_no_exists")
            redirect_to data_portability_path
          end
        else
          flash[:error] = t("decidim.account.data_portability_export.invalid_token")
          redirect_to data_portability_path
        end
      else
        flash[:error] = t("decidim.account.data_portability_export.no_token")
        redirect_to data_portability_path
      end
    end

    private

    def export_format
      "CSV"
    end
  end
end
