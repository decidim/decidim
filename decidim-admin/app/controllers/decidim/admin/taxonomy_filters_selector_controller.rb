# frozen_string_literal: true

module Decidim
  module Admin
    class TaxonomyFiltersSelectorController < Decidim::Admin::ApplicationController
      layout "decidim/admin/taxonomy_filters_selector"

      helper_method :name, :root_taxonomy, :taxonomy_filter

      def index
        enforce_permission_to :index, :taxonomy_filter
      end

      # Returns non-layout views of for use in selecting filters for components or other places using a drawer.
      def show
        enforce_permission_to :show, :taxonomy_filter
      end

      private

      def name
        @name ||= params[:name]
      end

      def root_taxonomy
        @root_taxonomy ||= Taxonomy.roots.find_by(id: params[:id])
      end

      def taxonomy_filter
        @taxonomy_filter ||= TaxonomyFilter.find_by(id: params[:filter_id])
      end
    end
  end
end
