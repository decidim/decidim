# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasTaxonomyFilters
        extend ActiveSupport::Concern

        included do
          before_action :set_controller_breadcrumb
          helper_method :collection, :current_taxonomy_filter, :breadcrumb_manage_partial
          layout "decidim/admin/taxonomy_filters"

          # GET /admin/taxonomy_filters
          def index
            enforce_permission_to :index, :taxonomy_filter
            render template: "decidim/admin/taxonomy_filters/index"
          end

          private

          def set_controller_breadcrumb
            controller_breadcrumb_items << {
              label: t("taxonomy_filters", scope: "decidim.admin.menu"),
              url: url_for(params[:controller]),
              active: false
            }

            return if params[:id].blank?

            controller_breadcrumb_items << {
              label: translated_attribute(current_taxonomy_filter.title),
              url: url_for(current_taxonomy_filter, controller: params[:controller], action: :edit),
              active: true
            }
          end

          def current_taxonomy_filter
            @current_taxonomy_filter ||= collection.find(params[:id])
          end

          def collection
            @collection ||= Decidim::Taxonomy.where(organization: current_organization)
          end

          # return a path to a partial if render that submenu
          def breadcrumb_manage_partial
            nil
          end
        end
      end
    end
  end
end
