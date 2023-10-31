# frozen_string_literal: true

module Decidim
  module Admin
    class StaticPageTopicsController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu

      helper_method :topic, :topics

      def index
        enforce_permission_to :read, :static_page_topic
      end

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
            redirect_to static_page_topics_path
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
            redirect_to static_page_topics_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("static_page_topics.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :destroy, :static_page_topic, static_page_topic: topic

        DestroyStaticPageTopic.call(topic, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("static_page_topics.destroy.success", scope: "decidim.admin")
            redirect_to static_page_topics_path
          end
        end
      end

      private

      def tab_menu_name = :admin_static_pages_menu

      def topic
        @topic ||= topics.find(params[:id])
      end

      def topics
        @topics ||= current_organization.static_page_topics
      end
    end
  end
end
