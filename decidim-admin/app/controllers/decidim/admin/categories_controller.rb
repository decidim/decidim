# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing categories.
    #
    class CategoriesController < Decidim::Admin::ApplicationController
      include ParticipatorySpaceAdminContext
      participatory_space_admin_layout

      def index
        enforce_permission_to :read, :category
      end

      def new
        enforce_permission_to :create, :category
        @form = form(CategoryForm).from_params({}, current_participatory_space: current_participatory_space)
      end

      def create
        enforce_permission_to :create, :category
        @form = form(CategoryForm).from_params(params, current_participatory_space: current_participatory_space)

        CreateCategory.call(@form, current_participatory_space, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.create.success", scope: "decidim.admin")
            redirect_to categories_path(current_participatory_space)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("categories.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        @category = collection.find(params[:id])
        enforce_permission_to :update, :category, category: @category
        @form = form(CategoryForm).from_model(@category, current_participatory_space: current_participatory_space)
      end

      def update
        @category = collection.find(params[:id])
        enforce_permission_to :update, :category, category: @category
        @form = form(CategoryForm).from_params(params, current_participatory_space: current_participatory_space)

        UpdateCategory.call(@category, @form, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.update.success", scope: "decidim.admin")
            redirect_to categories_path(current_participatory_space)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("categories.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def show
        @category = collection.find(params[:id])
        enforce_permission_to :read, :category, category: @category
      end

      def destroy
        @category = collection.find(params[:id])
        enforce_permission_to :destroy, :category, category: @category

        DestroyCategory.call(@category, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("categories.destroy.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("categories.destroy.error", scope: "decidim.admin")
          end

          redirect_back(fallback_location: categories_path(current_participatory_space))
        end
      end

      private

      def collection
        @collection ||= current_participatory_space.categories.includes(:subcategories)
      end
    end
  end
end
