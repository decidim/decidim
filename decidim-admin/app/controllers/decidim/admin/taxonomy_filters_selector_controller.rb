# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomyFiltersSelectorController < Decidim::Admin::ApplicationController
      layout "decidim/admin/taxonomy_filters_selector"

      helper_method :root_taxonomy, :taxonomy_filter, :component, :component_filters, :field_name

      # ensure component is valid
      before_action do
        raise Decidim::ActionForbidden unless component && component.organization == current_organization
      end

      before_action except: :index do
        redirect_to taxonomy_filters_selector_index_path(component_id: params[:component_id]) if root_taxonomy.nil?
      end

      before_action except: [:index, :new, :destroy] do
        redirect_to new_taxonomy_filters_selector_path(component_id: params[:component_id], taxonomy_id: params[:taxonomy_id]) if taxonomy_filter.nil?
      end

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

        update_filters!(component.settings.taxonomy_filters + [taxonomy_filter.id.to_s])

        render partial: "decidim/admin/taxonomy_filters_selector/component_table"
      end

      # Renders the component with the selected taxonomy filter
      def show
        enforce_permission_to :show, :taxonomy_filter
      end

      # Removes the selected taxonomy filter from the component
      def destroy
        enforce_permission_to :destroy, :taxonomy_filter

        update_filters!(component.settings.taxonomy_filters - [taxonomy_filter.id.to_s]) if taxonomy_filter

        render partial: "decidim/admin/taxonomy_filters_selector/component_table"
      end

      private

      def update_filters!(filter_ids)
        Decidim.traceability.perform_action!("update_filters", component, current_user) do
          component.update!(settings: { taxonomy_filters: filter_ids.map(&:to_s).uniq })
        end
      end

      def field_name
        "component[settings][taxonomy_filters][]"
      end

      def component_filters
        @component_filters ||= root_taxonomy.taxonomy_filters.where(id: component.settings.taxonomy_filters)
      end

      def component
        @component ||= Component.find_by(id: params[:component_id])
      end

      def root_taxonomy
        @root_taxonomy ||= current_organization.taxonomies.roots.find_by(id: params[:taxonomy_id])
      end

      def taxonomy_filter
        @taxonomy_filter ||= root_taxonomy.taxonomy_filters.find_by(id: params[:taxonomy_filter_id])
      end
    end
  end
end
