# frozen_string_literal: true

module Decidim
  module System
    # Controller that allows managing OAuth applications at the admin panel.
    #
    class OAuthApplicationsController < Decidim::System::ApplicationController
      helper Decidim::Admin::AttributesDisplayHelper

      def index
        @oauth_applications = collection.page(params[:page]).per(15)
      end

      def show
        @oauth_application = collection.find(params[:id])
      end

      def new
        @form = form(OAuthApplicationForm).instance
      end

      def create
        @form = form(OAuthApplicationForm).from_params(params)

        CreateOAuthApplication.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("oauth_applications.create.success", scope: "decidim.system")
            redirect_to action: :index
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("oauth_applications.create.error", scope: "decidim.system")
            render :new
          end
        end
      end

      def edit
        @oauth_application = collection.find(params[:id])
        @form = form(OAuthApplicationForm).from_model(@oauth_application)
      end

      def update
        @oauth_application = collection.find(params[:id])
        @form = form(OAuthApplicationForm).from_params({ organization_logo: @oauth_application.organization_logo }.merge(params.to_unsafe_h))

        UpdateOAuthApplication.call(@oauth_application, @form, current_user) do
          on(:ok) do |_application|
            flash[:notice] = I18n.t("oauth_applications.update.success", scope: "decidim.system")
            redirect_to action: :index
          end

          on(:invalid) do |application|
            @oauth_application = application
            flash.now[:error] = I18n.t("oauth_applications.update.error", scope: "decidim.system")
            render action: :edit
          end
        end
      end

      def destroy
        @oauth_application = collection.find(params[:id])

        DestroyOAuthApplication.call(@oauth_application, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("oauth_applications.destroy.success", scope: "decidim.system")
            redirect_to action: :index
          end

          on(:invalid) do
            flash.now[:error] = I18n.t("oauth_applications.destroy.error", scope: "decidim.system")
            redirect_to :back
          end
        end
      end

      private

      def collection
        @collection ||= Decidim::OAuthApplication.all.includes([:organization])
      end
    end
  end
end
