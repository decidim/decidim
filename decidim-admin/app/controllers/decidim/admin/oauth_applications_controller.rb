# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing OAuth applications at the admin panel.
    #
    class OAuthApplicationsController < Admin::ApplicationController
      def index
        enforce_permission_to :read, :oauth_application
        @oauth_applications = collection.page(params[:page]).per(15)
      end

      def show
        @oauth_application = collection.find(params[:id])
        enforce_permission_to :read, :oauth_application
      end

      def new
        enforce_permission_to :create, :oauth_application
        @form = form(OAuthApplicationForm).instance
      end

      def create
        enforce_permission_to :create, :oauth_application

        @form = form(OAuthApplicationForm).from_params(params)

        CreateOAuthApplication.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("oauth_applications.create.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("oauth_applications.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        @oauth_application = collection.find(params[:id])
        enforce_permission_to :update, :oauth_application, oauth_application: @oauth_application
        @form = form(OAuthApplicationForm).from_model(@oauth_application)
      end

      def update
        @oauth_application = collection.find(params[:id])
        enforce_permission_to :update, :oauth_application, oauth_application: @oauth_application
        @form = form(OAuthApplicationForm).from_params({ organization_logo: @oauth_application.organization_logo }.merge(params.to_unsafe_h))

        UpdateOAuthApplication.call(@oauth_application, @form, current_user) do
          on(:ok) do |_application|
            flash[:notice] = I18n.t("oauth_applications.update.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do |application|
            @oauth_application = application
            flash.now[:error] = I18n.t("oauth_applications.update.error", scope: "decidim.admin")
            render action: :edit
          end
        end
      end

      def destroy
        @oauth_application = collection.find(params[:id])
        enforce_permission_to :destroy, :oauth_application, oauth_application: @oauth_application

        DestroyOAuthApplication.call(@oauth_application, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("oauth_applications.destroy.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash.now[:error] = I18n.t("oauth_applications.destroy.error", scope: "decidim.admin")
            redirect_to :back
          end
        end
      end

      private

      def collection
        @collection ||= current_organization.oauth_applications
      end
    end
  end
end
