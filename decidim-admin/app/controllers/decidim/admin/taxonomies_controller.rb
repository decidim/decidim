# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomiesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu
      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      helper_method :taxonomies, :parent_options

      def index; end

      def new
        # enforce_permission_to :create, :taxonomy
        @form = form(Decidim::Admin::TaxonomyForm).instance
      end

      def edit
        # enforce_permission_to :update, :taxonomy
        @form = form(Decidim::Admin::TaxonomyForm).from_model(taxonomy)
      end

      def update
        # enforce_permission_to :update, :taxonomy
        @form = form(Decidim::Admin::TaxonomyForm).from_params(params)

        UpdateTaxonomy.call(@form, taxonomy) do
          on(:ok) do |taxonomy|
            flash[:notice] = I18n.t("taxonomies.update.success", scope: "decidim.taxonomies")
            redirect_to taxonomies_path(taxonomy)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("taxonomies.update.invalid", scope: "decidim.taxonomies")
            render action: "edit"
          end
        end
      end

      def create
        # enforce_permission_to :create, :taxonomy
        @form = form(Decidim::Admin::TaxonomyForm).from_params(params)

        CreateTaxonomy.call(@form, current_organization) do
          on(:ok) do |taxonomy|
            flash[:notice] = I18n.t("taxonomies.create.success", scope: "decidim.taxonomies")
            redirect_to taxonomies_path(taxonomy)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("taxonomies.create.invalid", scope: "decidim.taxonomies")
            render action: "new"
          end
        end
      end

      private

      def taxonomies
        @taxonomies ||= Decidim::Taxonomy.where(organization: current_organization)
      end

      def taxonomy
        @taxonomy ||= Decidim::Taxonomy.find(params[:id])
      end

      def parent_options
        @parent_options ||= Decidim::Taxonomy.where(decidim_organization_id: current_organization.id).map do |taxonomy|
          [translated_attribute(taxonomy.name), taxonomy.id]
        end
      end

      def tab_menu_name = :admin_taxonomies_menu
    end
  end
end
