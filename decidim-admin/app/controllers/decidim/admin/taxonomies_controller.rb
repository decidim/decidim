# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomiesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Filterable

      layout "decidim/admin/settings"

      helper_method :taxonomies, :parent_options, :taxonomy

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
          on(:ok) do |taxonomy|
            flash[:notice] = I18n.t("create.success", scope: "decidim.admin.taxonomies")
            redirect_to taxonomies_path(taxonomy)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("create.invalid", scope: "decidim.admin.taxonomies")
            render action: "new"
          end
        end
      end

      def edit
        enforce_permission_to :update, :taxonomy
        @form = form(Decidim::Admin::TaxonomyForm).from_model(taxonomy)
        @query = taxonomy.children.ransack(params[:q])
      end

      def update
        enforce_permission_to :update, :taxonomy

        @form = form(Decidim::Admin::TaxonomyForm).from_params(params)

        UpdateTaxonomy.call(@form, taxonomy) do
          on(:ok) do |taxonomy|
            flash[:notice] = I18n.t("update.success", scope: "decidim.admin.taxonomies")
            redirect_to taxonomies_path(taxonomy)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.admin.taxonomies")
            render action: "edit"
          end
        end
      end

      def destroy
        enforce_permission_to :destroy, :taxonomy

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
        @taxonomy ||= base_query.find(params[:id])
      end

      def parent_options(current_taxonomy = nil)
        options = Decidim::Taxonomy.where(decidim_organization_id: current_organization.id)
        options = options.where.not(id: current_taxonomy.id) if current_taxonomy.present?

        options.map do |taxonomy|
          [translated_attribute(taxonomy.name), taxonomy.id]
        end
      end

      def base_query
        Decidim::Taxonomy.where(organization: current_organization)
      end
    end
  end
end
