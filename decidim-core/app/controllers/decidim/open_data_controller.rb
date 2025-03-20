# frozen_string_literal: true

module Decidim
  class OpenDataController < Decidim::ApplicationController
    def download
      if uploader.attached?
        redirect_to uploader.path
      else
        schedule_open_data_generation
        flash[:alert] = t("decidim.open_data.not_available_yet")
        redirect_back fallback_location: root_path
      end
    end

    private

    def uploader
      @uploader ||= Decidim::ApplicationUploader.new(current_organization, :open_data_file)
    end

    def schedule_open_data_generation
      OpenDataJob.perform_later(current_organization)
    end
  end
end
