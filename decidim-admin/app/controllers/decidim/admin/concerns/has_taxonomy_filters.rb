# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasTaxonomyFilters
        extend ActiveSupport::Concern

        included do
          before_action :set_controller_breadcrumb
          helper_method :collection, :current_taxonomy_filter, :breadcrumb_manage_partial, :root_taxonomies, :participatory_space_manifest
          layout "decidim/admin/taxonomy_filters"

          # GET /admin/taxonomy_filters
          def index
            enforce_permission_to :index, :taxonomy_filter
            render template: "decidim/admin/taxonomy_filters/index"
          end

          def new
            enforce_permission_to :create, :taxonomy_filter
            @form = form(Decidim::Admin::TaxonomyFilterForm).from_params(root_taxonomy_id: params[:root_taxonomy_id])
            render template: "decidim/admin/taxonomy_filters/new"
          end

          def create
            enforce_permission_to :create, :taxonomy_filter
            @form = form(Decidim::Admin::TaxonomyFilterForm).from_params(params, participatory_space_manifest:)
            CreateTaxonomyFilter.call(@form) do
              on(:ok) do
                flash[:notice] = I18n.t("create.success", scope: "decidim.admin.taxonomy_filters")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("create.error", scope: "decidim.admin.taxonomy_filters")
                render template: "decidim/admin/taxonomy_filters/new"
              end
            end
          end

          def edit
            enforce_permission_to :update, :taxonomy_filter, taxonomy_filter: current_taxonomy_filter
            @form = form(Decidim::Admin::TaxonomyFilterForm).from_model(current_taxonomy_filter)
            render template: "decidim/admin/taxonomy_filters/edit"
          end

          def update
            enforce_permission_to :update, :taxonomy_filter, taxonomy_filter: current_taxonomy_filter
            @form = form(Decidim::Admin::TaxonomyFilterForm).from_params(params, participatory_space_manifest:)
            @form.all_taxonomy_items
            UpdateTaxonomyFilter.call(@form, current_taxonomy_filter) do
              on(:ok) do
                flash[:notice] = I18n.t("update.success", scope: "decidim.admin.taxonomy_filters")
                redirect_to action: :index
              end
              on(:invalid) do
                flash.now[:alert] = I18n.t("update.error", scope: "decidim.admin.taxonomy_filters")
                render template: "decidim/admin/taxonomy_filters/edit"
              end
            end
          end

          def destroy
            enforce_permission_to :destroy, :taxonomy_filter, taxonomy_filter: current_taxonomy_filter
            DestroyTaxonomyFilter.call(current_taxonomy_filter, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("destroy.success", scope: "decidim.admin.taxonomy_filters")
                redirect_to action: :index
              end
              on(:invalid) do
                flash[:alert] = I18n.t("destroy.error", scope: "decidim.admin.taxonomy_filters")
                redirect_to action: :index
              end
            end
          end

          private

          def set_controller_breadcrumb
            controller_breadcrumb_items << {
              label: t("taxonomy_filters", scope: "decidim.admin.menu"),
              url: url_for(controller: params[:controller]),
              active: false
            }
            return if params[:id].blank?

            controller_breadcrumb_items << {
              label: translated_attribute(current_taxonomy_filter.name),
              url: url_for(id: params[:id], controller: params[:controller], action: :edit),
              active: true
            }
          end

          def collection
            @collection ||= TaxonomyFilter.for(participatory_space_manifest).where(root_taxonomy: root_taxonomies)
          end

          def current_taxonomy_filter
            @current_taxonomy_filter ||= collection.find(params[:id])
          end

          def root_taxonomies
            @root_taxonomies ||= current_organization.taxonomies.roots
          end

          # Implement and return a valid (registered) participatory space manifest as a symbol (ie: :assemblies)
          def participatory_space_manifest
            raise NotImplementedError
          end

          # Override and return a path to a partial if you need to render the manage dropdown submenu
          def breadcrumb_manage_partial
            nil
          end
        end
      end
    end
  end
end
