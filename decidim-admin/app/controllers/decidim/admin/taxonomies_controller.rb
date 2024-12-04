# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomiesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Taxonomies::Filterable

      layout "decidim/admin/settings"

      before_action :set_taxonomies_breadcrumb_item
      before_action only: :edit do
        redirect_to edit_taxonomy_path(taxonomy.parent) unless taxonomy && taxonomy.root?
      end

      helper_method :collection, :parent_options, :taxonomy

      def index
        enforce_permission_to :index, :taxonomy
        @taxonomies = filtered_collection
      end

      def new
        enforce_permission_to :create, :taxonomy
        add_breadcrumb_item :new, decidim_admin.new_taxonomy_path

        @form = form(Decidim::Admin::TaxonomyForm).instance
      end

      def create
        enforce_permission_to :create, :taxonomy
        add_breadcrumb_item :new, decidim_admin.new_taxonomy_path

        @form = form(Decidim::Admin::TaxonomyForm).from_params(params)
        CreateTaxonomy.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("create.success", scope: "decidim.admin.taxonomies")
            redirect_to taxonomies_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("create.invalid", scope: "decidim.admin.taxonomies")
            render action: "new"
          end
        end
      end

      def edit
        enforce_permission_to(:update, :taxonomy, taxonomy:)
        add_breadcrumb_item :edit, decidim_admin.edit_taxonomy_path(taxonomy)

        @form = form(Decidim::Admin::TaxonomyForm).from_model(taxonomy)
        @taxonomies = filtered_collection
      end

      def update
        enforce_permission_to(:update, :taxonomy, taxonomy:)
        add_breadcrumb_item :edit, decidim_admin.edit_taxonomy_path(taxonomy)

        @form = form(Decidim::Admin::TaxonomyForm).from_params(params)

        UpdateTaxonomy.call(@form, taxonomy) do
          on(:ok) do
            flash[:notice] = I18n.t("update.success", scope: "decidim.admin.taxonomies")
            redirect_to taxonomies_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.admin.taxonomies")
            render action: "edit"
          end
        end
      end

      def destroy
        enforce_permission_to(:destroy, :taxonomy, taxonomy:)

        DestroyTaxonomy.call(taxonomy, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("destroy.success", scope: "decidim.admin.taxonomies")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("destroy.invalid", scope: "decidim.admin.taxonomies")
          end
        end
        redirect_back(fallback_location: taxonomies_path)
      end

      def reorder
        enforce_permission_to :update, :taxonomy

        ReorderTaxonomies.call(current_organization, params[:ids_order], page_offset) do
          on(:ok) do
            head :ok
          end

          on(:invalid) do
            head :bad_request
          end
        end
      end

      private

      def collection
        @collection ||= taxonomy ? taxonomy.children : root_taxonomies
      end

      def root_taxonomies
        @root_taxonomies ||= current_organization.taxonomies.roots
      end

      def taxonomy
        @taxonomy ||= current_organization.taxonomies.find_by(id: params[:id])
      end

      def set_taxonomies_breadcrumb_item
        add_breadcrumb_item I18n.t("menu.taxonomies", scope: "decidim.admin"), decidim_admin.taxonomies_path
      end

      def add_breadcrumb_item(key, url)
        controller_breadcrumb_items << {
          label: I18n.t(key, scope: "decidim.admin.taxonomies.breadcrumb", default: key),
          url:
        }
      end
    end
  end
end
