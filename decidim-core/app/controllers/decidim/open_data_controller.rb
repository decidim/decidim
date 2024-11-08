# frozen_string_literal: true

module Decidim
  class OpenDataController < Decidim::ApplicationController
    helper_method :open_data_component_manifests, :open_data_participatory_space_manifests, :open_data_core

    def index; end

    def download
      resource = params[:resource] || nil

      if open_data_file_for_resource(resource)
        file = open_data_file_for_resource(resource)
        send_data file.download, filename: file.blob.filename.to_s, type: file.blob.content_type
      else
        schedule_open_data_generation(resource)
        flash[:alert] = t("decidim.open_data.not_available_yet")
        redirect_back fallback_location: open_data_path
      end
    end

    private

    def open_data_core
      [:users, :user_groups, :metrics]
    end

    def open_data_component_manifests
      @open_data_component_manifests ||= Decidim.component_manifests
                                                .flat_map(&:export_manifests)
                                                .select(&:include_in_open_data?)
    end

    def open_data_participatory_space_manifests
      @open_data_participatory_space_manifests ||= Decidim.participatory_space_manifests
                                                          .flat_map(&:export_manifests)
                                                          .select(&:include_in_open_data?)
    end

    def open_data_file_for_resource(resource)
      current_organization.open_data_files.all.find do |file|
        file.blob.filename == current_organization.open_data_file_path(resource)
      end
    end

    def schedule_open_data_generation(resource = nil)
      OpenDataJob.perform_later(current_organization, resource)
    end
  end
end
