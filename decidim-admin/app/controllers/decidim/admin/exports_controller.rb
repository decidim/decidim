# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class ExportsController < Decidim::Admin::ApplicationController
      include Decidim::FeaturePathHelper

      def create
        authorize! :manage, feature
        name = params[:id]

        ExportJob.perform_later(current_user, feature, name, params[:format] || default_format)

        flash[:notice] = t("decidim.admin.exports.notice")

        redirect_back(fallback_location: manage_feature_path(feature))
      end

      private

      def default_format
        "json"
      end

      def feature
        @feature ||= current_participatory_space.features.find(params[:feature_id])
      end
    end
  end
end
