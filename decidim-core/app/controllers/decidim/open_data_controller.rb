# frozen_string_literal: true

module Decidim
  class OpenDataController < Decidim::ApplicationController
    def download
      if file.exists?
        schedule_open_data_generation if File.mtime(file.file) < 1.day.ago
        redirect_to file.url
      else
        schedule_open_data_generation
        flash[:warn] = t("decidim.open_data.not_available_yet")
        redirect_back fallback_location: root_path
      end
    end

    private

    def file
      current_organization.open_data_file
    end

    def schedule_open_data_generation
      OpenDataJob.perform_later(current_organization)
    end
  end
end
