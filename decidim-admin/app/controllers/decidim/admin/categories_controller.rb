# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing categories.
    #
    class CategoriesController < Decidim::Admin::ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def index
        authorize! :read, Decidim::Category
      end

      def new
        authorize! :create, Decidim::Category
        @form = form(CategoryForm).from_params({}, current_process: current_participatory_process)
      end

      def create
        authorize! :create, Decidim::Category
        @form = form(CategoryForm).from_params(params, current_process: current_participatory_process)

        CreateCategory.call(@form, current_participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.create.success", scope: "decidim.admin")
            redirect_to categories_path(current_participatory_process)
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
        @form = form(CategoryForm).from_model(@category, current_process: current_participatory_process)
      end

      def update
        @category = collection.find(params[:id])
        authorize! :update, @category
        @form = form(CategoryForm).from_params(params, current_process: current_participatory_process)

        UpdateCategory.call(@category, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.update.success", scope: "decidim.admin")
            redirect_to categories_path(current_participatory_process)
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
            flash[:alert] = I18n.t("categories.destroy.error", scope: "decidim.admin")
          end

          redirect_back(fallback_location: categories_path(current_participatory_process))
        end
      end

      private

      def collection
        @collection ||= current_participatory_process.categories.includes(:subcategories)
      end
    end
  end
end
