# frozen_string_literal: true

module Decidim
  class OpenDataController < Decidim::ApplicationController
    def download
      if open_data_file_exists?
        redirect_to uploader.url
      else
        schedule_open_data_generation
        flash[:alert] = t("decidim.open_data.not_available_yet")
        redirect_back fallback_location: root_path
      end
    end

    private

    def open_data_file_exists?
      uploader.file.exists?
    rescue StandardError
      false
    end

    def uploader
      current_organization.open_data_file
    end

    def schedule_open_data_generation
      OpenDataJob.perform_later(current_organization)
    end
  end
end
