# frozen_string_literal: true

module Decidim
  module Admin
    class StaticPageTopicsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/pages"
      helper_method :topic

      def new
        enforce_permission_to :create, :static_page_topic
        @form = form(StaticPageTopicForm).instance
      end

      def create
        enforce_permission_to :create, :static_page_topic
        @form = form(StaticPageTopicForm).from_params(params["static_page_topic"])

        CreateStaticPageTopic.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("static_page_topics.create.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("static_page_topics.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to :update, :static_page_topic, static_page_topic: topic
        @form = form(StaticPageTopicForm).from_model(topic)
      end

      def update
        enforce_permission_to :update, :static_page_topic, static_page_topic: topic
        @form = form(StaticPageTopicForm).from_params(params["static_page_topic"])

        UpdateStaticPageTopic.call(topic, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("static_page_topics.update.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("static_page_topics.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :destroy, :static_page_topic, static_page_topic: topic

        DestroyStaticPage.call(topic, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("static_page_topics.destroy.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end
        end
      end

      private

      def topic
        @topic ||= StaticPageTopic.where(
          organization: current_organization
        ).find(params[:id])
      end
    end
  end
end
