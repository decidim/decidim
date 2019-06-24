# frozen_string_literal: true

module Decidim
  module Admin
    class CategoriesImportsController < Admin::ApplicationController
      def new
        enforce_permission_to :create, :category

        @form = form(Admin::ImportCategoriesForm).instance
      end

      def create
        enforce_permission_to :create, :category

        @form = form(Admin::ImportCategoriesForm).from_params(params)
        Admin::ImportCategoriesFromAnotherSpace.call(@form) do
          on(:ok) do |categories|
            flash[:notice] = I18n.t("categories.import.create.success", scope: "decidim.admin", number: categories.length)
            redirect_to categories_path(current_participatory_space)
          end

          on(:invalid) do
            flash[:alert] = I18n.t("categories.import.create.error", scope: "decidim.admin")
            render action: "new"
          end
        end
      end
    end
  end
end
