# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class ExportsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def create
        authorize! :manage, feature
        name = params[:id]

        ExportJob.perform_later(current_user, feature, name, params[:format] || default_format)

        flash[:notice] = t("decidim.admin.exports.notice")

        redirect_back(fallback_location: fallback_location)
      end

      private

      def fallback_location
        send(
          "decidim_admin_#{feature.manifest.name}_path",
          feature_id: feature.id,
          participatory_process_id: participatory_process.id
        )
      end

      def default_format
        "json"
      end

      def feature
        @feature ||= participatory_process.features.find(params[:feature_id])
      end
    end
  end
end
