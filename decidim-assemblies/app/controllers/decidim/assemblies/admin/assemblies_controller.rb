# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assemblies.
      #
      class AssembliesController < Decidim::Assemblies::Admin::ApplicationController
        include Decidim::Assemblies::Admin::Filterable
        include Decidim::Admin::ParticipatorySpaceAdminBreadcrumb
        helper_method :current_assembly, :parent_assembly, :current_participatory_space, :deleted_collection
        layout "decidim/admin/assemblies"

        def index
          enforce_permission_to :read, :assembly_list
          @assemblies = filtered_collection.not_deleted
        end

        def new
          enforce_permission_to :create, :assembly
          @form = form(AssemblyForm).instance
          @form.parent_id = params[:parent_id]
        end

        def create
          enforce_permission_to :create, :assembly
          @form = form(AssemblyForm).from_params(params)

          CreateAssembly.call(@form) do
            on(:ok) do |assembly|
              flash[:notice] = I18n.t("assemblies.create.success", scope: "decidim.admin")
              redirect_to assemblies_path(q: { parent_id_eq: assembly.parent_id })
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :assembly, assembly: current_assembly
          @form = form(AssemblyForm).from_model(current_assembly)
          render layout: "decidim/admin/assembly"
        end

        def update
          enforce_permission_to :update, :assembly, assembly: current_assembly
          @form = form(AssemblyForm).from_params(
            assembly_params,
            assembly_id: current_assembly.id
          )

          UpdateAssembly.call(@form, current_assembly) do
            on(:ok) do |assembly|
              flash[:notice] = I18n.t("assemblies.update.success", scope: "decidim.admin")
              redirect_to edit_assembly_path(assembly)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/assembly"
            end
          end
        end

        def copy
          enforce_permission_to :create, :assembly
        end

        def soft_delete
          enforce_permission_to :soft_delete, :assembly, assembly: current_assembly

          Decidim::Commands::SoftDeleteResource.call(current_assembly, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies.soft_delete.success", scope: "decidim.admin")
              redirect_to assemblies_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("assemblies.soft_delete.error", scope: "decidim.admin")
              redirect_to assemblies_path
            end
          end
        end

        def restore
          enforce_permission_to :restore, :assembly, assembly: current_assembly

          Decidim::Commands::RestoreResource.call(current_assembly, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies.restore.success", scope: "decidim.admin")
              redirect_to deleted_assemblies_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("assemblies.restore.error", scope: "decidim.admin")
              redirect_to deleted_assemblies_path
            end
          end
        end

        private

        def collection
          @collection ||= OrganizationAssemblies.new(current_user.organization).query
        end

        def deleted_collection
          @deleted_collection ||= filtered_collection.trashed
        end

        def current_assembly
          @current_assembly ||= collection.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end

        alias current_participatory_space current_assembly

        def parent_assembly
          @parent_assembly ||= collection.find_by(id: ransack_params[:parent_id_eq])
        end

        def assembly_params
          { id: params[:slug] }.merge(params[:assembly].to_unsafe_h)
        end
      end
    end
  end
end
