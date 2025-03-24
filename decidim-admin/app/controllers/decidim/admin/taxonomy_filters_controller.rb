# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomyFiltersController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Taxonomies::Filterable

      layout "decidim/admin/settings"

      before_action :set_taxonomies_breadcrumb_item
      before_action only: :edit do
        redirect_to taxonomy_filters_path(root_taxonomy) unless taxonomy_filter && root_taxonomy == taxonomy_filter.root_taxonomy
      end

      helper_method :collection, :root_taxonomy, :taxonomy_filter

      # Returns non-layout views of for use in selecting filters for components or other places using a drawer.
      def show
        enforce_permission_to :show, :taxonomy_filter
      end

      def index
        enforce_permission_to :index, :taxonomy_filter
      end

      def new
        enforce_permission_to :create, :taxonomy_filter
        add_breadcrumb_item :new, decidim_admin.new_taxonomy_filter_path
        @form = form(Decidim::Admin::TaxonomyFilterForm).from_params(root_taxonomy_id: params[:taxonomy_id])
      end

      def create
        enforce_permission_to :create, :taxonomy_filter
        add_breadcrumb_item :new, decidim_admin.new_taxonomy_filter_path
        @form = form(Decidim::Admin::TaxonomyFilterForm).from_params(params)
        CreateTaxonomyFilter.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("create.success", scope: "decidim.admin.taxonomy_filters")
            redirect_to decidim_admin.taxonomy_filters_path(root_taxonomy)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("create.error", scope: "decidim.admin.taxonomy_filters")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to(:update, :taxonomy_filter, taxonomy_filter:)
        add_breadcrumb_item :edit, decidim_admin.edit_taxonomy_filter_path
        @form = form(Decidim::Admin::TaxonomyFilterForm).from_model(taxonomy_filter)
      end

      def update
        enforce_permission_to(:update, :taxonomy_filter, taxonomy_filter:)
        add_breadcrumb_item :edit, decidim_admin.edit_taxonomy_filter_path
        @form = form(Decidim::Admin::TaxonomyFilterForm).from_params(params)
        UpdateTaxonomyFilter.call(@form, taxonomy_filter) do
          on(:ok) do
            flash[:notice] = I18n.t("update.success", scope: "decidim.admin.taxonomy_filters")
            redirect_to decidim_admin.taxonomy_filters_path(root_taxonomy)
          end
          on(:invalid) do
            flash.now[:alert] = I18n.t("update.error", scope: "decidim.admin.taxonomy_filters")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to(:destroy, :taxonomy_filter, taxonomy_filter:)
        DestroyTaxonomyFilter.call(taxonomy_filter, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("destroy.success", scope: "decidim.admin.taxonomy_filters")
          end
          on(:invalid) do
            flash[:alert] = I18n.t("destroy.error", scope: "decidim.admin.taxonomy_filters")
          end
        end
        redirect_back(fallback_location: decidim_admin.taxonomy_filters_path(root_taxonomy))
      end

      private

      def collection
        @collection ||= root_taxonomy.taxonomy_filters
      end

      def root_taxonomy
        @root_taxonomy ||= Taxonomy.roots.find(params[:taxonomy_id])
      end

      def taxonomy_filter
        @taxonomy_filter ||= TaxonomyFilter.find_by(id: params[:id])
      end

      def set_taxonomies_breadcrumb_item
        add_breadcrumb_item I18n.t("menu.taxonomies", scope: "decidim.admin"), decidim_admin.taxonomies_path
        add_breadcrumb_item root_taxonomy.name, decidim_admin.taxonomy_filters_path(root_taxonomy)
        add_breadcrumb_item :filters, decidim_admin.taxonomy_filters_path(root_taxonomy)
      end

      def add_breadcrumb_item(key, url)
        controller_breadcrumb_items << {
          label: I18n.t(key, scope: "decidim.admin.taxonomy_filters.breadcrumb", default: key),
          url:
        }
      end
    end
  end
end
