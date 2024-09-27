# frozen_string_literal: true

module Decidim
  module Admin
    class AuthorizationExportsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      def index
        enforce_permission_to :index, :authorization_workflow

        @workflows = Decidim::Verifications.workflows.select do |manifest|
          current_organization.available_authorizations.include?(manifest.name.to_s)
        end

        @form = form(AuthorizationExportsForm).instance
      end

      def create
        AuthorizationExportsJob.perform_later(
          current_user,
          authorization_params[:authorization_handler_name],
          authorization_params[:start_date],
          authorization_params[:end_date]
        )

        flash[:notice] = t("decidim.admin.exports.notice")

        redirect_to authorization_exports_path
      end

      private

      def authorization_params
        params.require(:authorization_exports).permit(:authorization_handler_name, :start_date, :end_date)
      end
    end
  end
end
