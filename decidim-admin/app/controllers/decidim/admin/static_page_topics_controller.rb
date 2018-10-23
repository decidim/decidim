# frozen_string_literal: true

module Decidim
  module Admin
    class StaticPageTopicsController < Decidim::Admin::ApplicationController
      helper_method :topic

      def new
        enforce_permission_to :create, :static_page
      end

      def create
        enforce_permission_to :create, :static_page
      end

      def edit
        enforce_permission_to :update, :static_page_topic, static_page_topic: topic
      end

      def update
        enforce_permission_to :update, :static_page_topic, static_page_topic: topic
      end

      def destroy
        enforce_permission_to :destroy, :static_page_topic, static_page_topic: topic
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
