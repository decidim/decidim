# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing categories.
    #
    class CategoriesController < Decidim::Admin::ApplicationController
      include ParticipatorySpaceAdminContext
      participatory_space_admin_layout

      before_action :find_category, except: [:index, :new, :create]
      before_action :set_categories_breadcrumb_items

      def index
        enforce_permission_to :read, :category
      end

      def new
        enforce_permission_to :create, :category
        @form = form(CategoryForm).from_params({}, current_participatory_space:)
      end

      def create
        enforce_permission_to :create, :category
        @form = form(CategoryForm).from_params(params, current_participatory_space:)

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
        enforce_permission_to :update, :category, category: @category
        @form = form(CategoryForm).from_model(@category, current_participatory_space:)
      end

      def update
        enforce_permission_to :update, :category, category: @category
        @form = form(CategoryForm).from_params(params, current_participatory_space:)

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

      def destroy
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

      def set_categories_breadcrumb_items
        return if @category.blank?

        controller_breadcrumb_items << {
          label: translated_attribute(@category.name),
          active: true
        }
      end

      def find_category
        @category ||= collection.find(params[:id])
      end

      def collection
        @collection ||= current_participatory_space.categories.includes(:subcategories)
      end
    end
  end
end
