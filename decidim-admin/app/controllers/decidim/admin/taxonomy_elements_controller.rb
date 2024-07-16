# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomyElementsController < Decidim::Admin::ApplicationController
      layout false

      helper_method :taxonomy, :taxonomy_element, :parent_options, :selected_parent_id

      def new
        # TODO: permissions
        @form = form(Decidim::Admin::TaxonomyElementForm).instance
      end

      def create
        # TODO: permissions
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
        # TODO: permissions
        @form = form(Decidim::Admin::TaxonomyElementForm).from_model(taxonomy_element)
      end

      def update
        # TODO: permissions
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
          options = [[translated_attribute(taxonomy.name), taxonomy.id]]
          taxonomy.children.each do |child|
            options.append(["#{translated_attribute(taxonomy.name)} -> #{translated_attribute(child.name)}", child.id]) unless child.id == taxonomy_element&.id
            # add children to the list with indentation
            child.children.each do |grandchild|
              unless grandchild.id == taxonomy_element&.id
                options.append ["#{translated_attribute(taxonomy.name)} -> #{translated_attribute(child.name)} -> #{translated_attribute(grandchild.name)}",
                                grandchild.id]
              end
            end
          end
          options
        end
      end
    end
  end
end
