# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomyFiltersSelectorController < Decidim::Admin::ApplicationController
      layout "decidim/admin/taxonomy_filters_selector"

      helper_method :root_taxonomy, :taxonomy_filter, :component, :component_filters

      # Renders "choose the taxonomy" step
      def index
        enforce_permission_to :index, :taxonomy_filter
      end

      # Renders "choose the taxonomy filter" step
      def new
        enforce_permission_to :create, :taxonomy_filter
      end

      # Updates the component with the selected taxonomy filter
      def create
        enforce_permission_to :create, :taxonomy_filter

        filter_ids = component.settings.taxonomy_filters + [taxonomy_filter.id]
        component.update!(settings: { taxonomy_filters: filter_ids.uniq })

        render partial: "decidim/admin/taxonomy_filters_selector/component_table"
      end

      # Renders the component with the selected taxonomy filter
      def show
        enforce_permission_to :show, :taxonomy_filter
      end

      # Removes the selected taxonomy filter from the component
      def destroy
        enforce_permission_to :destroy, :taxonomy_filter

        filter_ids = component.settings.taxonomy_filters - [taxonomy_filter.id]
        component.update!(settings: { taxonomy_filters: filter_ids })

        render partial: "decidim/admin/taxonomy_filters_selector/component_table"
      end

      private

      def component_filters
        @component_filters ||= TaxonomyFilter.for(current_organization).where(id: component.settings.taxonomy_filters)
      end

      def component
        @component ||= Component.find(params[:component_id])
      end

      def root_taxonomy
        @root_taxonomy ||= Taxonomy.roots.find_by(id: params[:taxonomy_id])
      end

      def taxonomy_filter
        @taxonomy_filter ||= TaxonomyFilter.find_by(id: params[:taxonomy_filter_id].presence || params[:id])
      end
    end
  end
end
