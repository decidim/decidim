# frozen_string_literal: true

module Decidim
  module Admin
    # This is an abstract controller allows sharing unpublished things.
    # Final implementation must inherit from this controller and implement the `resource` method.
    class ShareTokensController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Filterable

      helper_method :current_token, :resource, :resource_title, :share_tokens_path

      def index
        enforce_permission_to :read, :share_tokens
        @share_tokens = filtered_collection
      end

      def new
        enforce_permission_to :create, :share_tokens
        @form = form(ShareTokenForm).instance
      end

      def create
        enforce_permission_to :create, :share_tokens
        @form = form(ShareTokenForm).from_params(params, resource:)

        CreateShareToken.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("share_tokens.create.success", scope: "decidim.admin")
            redirect_to share_tokens_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("share_tokens.create.invalid", scope: "decidim.admin")
            render action: "new"
          end
        end
      end

      def edit
        enforce_permission_to(:update, :share_tokens, share_token: current_token)
        @form = form(ShareTokenForm).from_model(current_token)
      end

      def update
        enforce_permission_to(:update, :share_tokens, share_token: current_token)
        @form = form(ShareTokenForm).from_params(params, resource:)

        UpdateShareToken.call(@form, current_token) do
          on(:ok) do
            flash[:notice] = I18n.t("share_tokens.update.success", scope: "decidim.admin")
            redirect_to share_tokens_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("share_tokens.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to(:destroy, :share_tokens, share_token: current_token)

        DestroyShareToken.call(current_token, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("share_tokens.destroy.success", scope: "decidim.admin")
          end
          on(:invalid) do
            flash[:error] = I18n.t("share_tokens.destroy.error", scope: "decidim.admin")
          end
        end

        redirect_to share_tokens_path
      end

      private

      # override this method in the destination controller to specify the resource associated with the shared token (ie: a component)
      def resource
        raise NotImplementedError
      end

      # Override also this method if resource does not respond to a translatable name or title
      def resource_title
        translated_attribute(resource.try(:name) || resource.title)
      end

      # sets the prefix for the route helper methods (this may vary depending on the resource type)
      # This setup works fine for participatory spaces and components, override if needed
      def route_name
        @route_name ||= "#{resource.manifest.route_name}_"
      end

      def route_proxy
        @route_proxy ||= EngineRouter.admin_proxy(resource.try(:participatory_space) || resource)
      end

      # returns the proper path for managing a share token according to the resource
      # this works fine for components and participatory spaces, override if needed
      def share_tokens_path(method = :index, options = {})
        args = resource.is_a?(Decidim::Component) ? [resource, options] : [options]

        case method
        when :index, :create
          route_proxy.send("#{route_name}share_tokens_path", *args)
        when :new
          route_proxy.send("new_#{route_name}share_token_path", *args)
        when :update, :destroy
          route_proxy.send("#{route_name}share_token_path", *args)
        when :edit
          route_proxy.send("edit_#{route_name}share_token_path", *args)
        end
      end

      def base_query
        collection
      end

      def collection
        @collection ||= Decidim::ShareToken.where(organization: current_organization, token_for: resource)
      end

      def filters
        []
      end

      def current_token
        @current_token ||= collection.find(params[:id])
      end
    end
  end
end
