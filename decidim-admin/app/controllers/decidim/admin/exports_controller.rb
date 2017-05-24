# frozen_string_literal: true
module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class ExportsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def create
        feature = participatory_process.features.find(params[:feature_id])
        authorize! :manage, feature
        name = params[:id]

        ExportJob.perform_later(current_user, feature, name, params[:format])

        flash[:notice] = t("decidim.#{name}.exports.notice")
        redirect_to :back
      end
    end
  end
end
