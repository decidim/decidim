# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomiesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Filterable

      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      helper_method :taxonomies, :parent_options, :taxonomy

      before_action only: :edit do
        redirect_to edit_taxonomy_path(taxonomy.parent) unless taxonomy && taxonomy.root?
      end

      def index
        @query = root_taxonomies.ransack(params[:q])
      end

      def new
        enforce_permission_to :create, :taxonomy

        @form = form(Decidim::Admin::TaxonomyForm).instance
      end

      def create
        enforce_permission_to :create, :taxonomy

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
        @form = form(Decidim::Admin::TaxonomyForm).from_model(taxonomy)
        @query = taxonomy.children.ransack(params[:q])
      end

      def update
        enforce_permission_to(:update, :taxonomy, taxonomy:)
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
            redirect_to taxonomies_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("destroy.invalid", scope: "decidim.admin.taxonomies")
            redirect_to taxonomies_path
          end
        end
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

      def taxonomies
        @taxonomies = @query.result
        @taxonomies = @taxonomies.search_by_name(params.dig(:q, :name_cont)) if params.dig(:q, :name_cont).present?
        @taxonomies = paginate(@taxonomies)
      end

      def root_taxonomies
        @root_taxonomies ||= base_query.where(parent_id: nil)
      end

      def taxonomy
        @taxonomy ||= base_query.find_by(id: params[:id])
      end

      def base_query
        Decidim::Taxonomy.where(organization: current_organization)
      end
    end
  end
end
