# frozen_string_literal: true

module Decidim
  module System
    class ApiUsersController < Decidim::System::ApplicationController
      helper ::Decidim::MetaTagsHelper
      helper ::Decidim::Admin::IconLinkHelper

      def index
        @api_users = api_users
      end

      def new
        @form = form(::Decidim::System::ApiUserForm).instance
      end

      def destroy
        Decidim.traceability.perform_action!("delete", api_user, current_admin) do
          api_user.destroy!
        end

        flash[:notice] = I18n.t("api_user.destroy.success", scope: "decidim.system")

        redirect_to action: :index
      end

      def update
        RefreshApiUserSecret.call(api_user, current_admin) do
          on(:ok) do |token|
            flash[:notice] = I18n.t("api_user.refresh.success", scope: "decidim.system", user: api_user.api_key)
            redirect_to action: :index, token: token, api_user: api_user
          end

          on(:invalid) do
            flash[:notice] = I18n.t("api_user.refresh.error", scope: "decidim.system")
            redirect_to action: :index
          end
        end
      end

      def create
        @form = ::Decidim::System::ApiUserForm.from_params(params.merge!(name: params[:admin][:name], organization: organization))
        CreateApiUser.call(@form, current_admin) do
          on(:ok) do |api_user, token|
            flash[:notice] = I18n.t("api_user.create.success", scope: "decidim.system", user: api_user.api_key)
            redirect_to action: :index, token: token, api_user: api_user
          end

          on(:invalid) do
            flash[:error] = I18n.t("api_user.create.error", scope: "decidim.system")
            render :new
          end
        end
      end

      private

      def api_users
        ::Decidim::Api::ApiUser.order(decidim_organization_id: :asc)
      end

      def api_user
        return unless params[:id]

        @api_user ||= ::Decidim::Api::ApiUser.find(params[:id])
      end

      def organization
        ::Decidim::Organization.find(params[:admin][:organization])
      end
    end
  end
end
