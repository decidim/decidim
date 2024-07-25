# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokensController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper
      include Decidim::Admin::Filterable

      helper_method :share_token, :component

      def index
        enforce_permission_to :read, :share_token
        @share_tokens = filtered_collection
      end

      def new
        enforce_permission_to :create, :share_token
        @form = form(ShareTokenForm).instance
      end

      def create
        enforce_permission_to :create, :share_token
        @form = form(ShareTokenForm).from_params(params, component:)

        CreateShareToken.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("share_tokens.create.success", scope: "decidim.admin")
            redirect_to share_tokens_path(component)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("share_tokens.create.invalid", scope: "decidim.admin")
            render action: "new"
          end
        end
      end

      def edit
        enforce_permission_to(:update, :share_token, share_token:)
        @form = form(ShareTokenForm).from_model(share_token)
      end

      def update
        enforce_permission_to(:update, :share_token, share_token:)
        @form = form(ShareTokenForm).from_params(params, component:)

        UpdateShareToken.call(@form, share_token) do
          on(:ok) do
            flash[:notice] = I18n.t("share_tokens.update.success", scope: "decidim.admin")
            redirect_to share_tokens_path(component)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("share_tokens.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to(:destroy, :share_token, share_token:)

        Decidim::Commands::DestroyResource.call(share_token, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("share_tokens.destroy.success", scope: "decidim.admin")
          end
          on(:invalid) do
            flash[:error] = I18n.t("share_tokens.destroy.error", scope: "decidim.admin")
          end
        end

        redirect_back(fallback_location: root_path)
      end

      private

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end

      def base_query
        collection
      end

      def collection
        @collection ||= Decidim::ShareToken.where(organization: current_organization, token_for: component)
      end

      def filters
        []
      end

      def share_token
        @share_token ||= collection.find(params[:id])
      end
    end
  end
end
