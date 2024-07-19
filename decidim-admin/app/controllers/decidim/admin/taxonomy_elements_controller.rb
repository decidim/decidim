# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomyElementsController < Decidim::Admin::ApplicationController
      layout false

      helper_method :taxonomy, :taxonomy_element, :parent_options, :selected_parent_id
      before_action do
        if taxonomy_element && taxonomy_element.parent_ids.exclude?(taxonomy.id)
          flash[:alert] = I18n.t("update.invalid", scope: "decidim.admin.taxonomies")
          render plain: I18n.t("update.invalid", scope: "decidim.admin.taxonomies"), status: :unprocessable_entity
        end
      end

      def new
        enforce_permission_to :create, :taxonomy_element
        @form = form(Decidim::Admin::TaxonomyElementForm).instance
      end

      def create
        enforce_permission_to :create, :taxonomy_element
        @form = form(Decidim::Admin::TaxonomyElementForm).from_params(params)
        CreateTaxonomy.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("create.success", scope: "decidim.admin.taxonomies")
            redirect_to edit_taxonomy_path(taxonomy)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("create.invalid", scope: "decidim.admin.taxonomies")
            render action: "new"
          end
        end
      end

      def edit
        enforce_permission_to :update, :taxonomy_element, taxonomy: taxonomy_element
        @form = form(Decidim::Admin::TaxonomyElementForm).from_model(taxonomy_element)
      end

      def update
        enforce_permission_to :update, :taxonomy_element, taxonomy: taxonomy_element
        @form = form(Decidim::Admin::TaxonomyElementForm).from_params(params)
        UpdateTaxonomy.call(@form, taxonomy_element) do
          on(:ok) do
            flash[:notice] = I18n.t("update.success", scope: "decidim.admin.taxonomies")
            redirect_to edit_taxonomy_path(taxonomy)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.admin.taxonomies")
            render action: "edit"
          end
        end
      end

      private

      def taxonomy
        @taxonomy ||= Decidim::Taxonomy.find_by(organization: current_organization, id: params[:taxonomy_id])
      end

      def taxonomy_element
        @taxonomy_element ||= Decidim::Taxonomy.find_by(organization: current_organization, id: params[:id])
      end

      def selected_parent_id
        @selected_parent_id ||= taxonomy_element&.parent_id || taxonomy.id
      end

      def parent_options
        @parent_options ||= begin
          options = [[I18n.t("new.none", scope: "decidim.admin.taxonomy_elements"), taxonomy.id]]
          taxonomy.children.each do |child|
            next if child.id == taxonomy_element&.id

            options << [translated_attribute(child.name).to_s, child.id]
            # add children to the list with indentation
            child.children.each do |grandchild|
              next if grandchild.id == taxonomy_element&.id

              options << ["&nbsp;&nbsp;&nbsp;#{translated_attribute(grandchild.name)}".html_safe, grandchild.id]
            end
          end
          options
        end
      end
    end
  end
end
