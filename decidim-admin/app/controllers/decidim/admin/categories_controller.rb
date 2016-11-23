# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class CategoriesController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def index
        authorize! :read, Decidim::Category
      end

      def new
        authorize! :create, Decidim::Category
        @form = form(CategoryForm).instance
      end

      def create
        authorize! :create, Decidim::Category
        @form = form(CategoryForm).from_params(params)

        CreateCategory.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.create.success", scope: "decidim.admin")
            redirect_to participatory_process_categories_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("categories.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        @category = collection.find(params[:id])
        authorize! :update, @category
        @form = form(CategoryForm).from_model(@category)
      end

      def update
        @category = collection.find(params[:id])
        authorize! :update, @category
        @form = form(CategoryForm).from_params(params)

        UpdateCategory.call(@category, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.update.success", scope: "decidim.admin")
            redirect_to participatory_process_categories_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("categories.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def show
        @category = collection.find(params[:id])
        authorize! :read, @category
      end

      def destroy
        @category = collection.find(params[:id])
        authorize! :destroy, @category

        DestroyCategory.call(@category) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.destroy.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("categories.destroy.error", scope: "decidim.admin")
          end

          redirect_back(fallback_location: participatory_process_categories_path(participatory_process))
        end
      end

      private

      def collection
        @collection ||= participatory_process.categories
      end
    end
  end
end
