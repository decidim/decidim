# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assemblies.
      #
      class AssembliesController < Decidim::Assemblies::Admin::ApplicationController
        include Decidim::Assemblies::Admin::Filterable
        include Decidim::Admin::ParticipatorySpaceAdminContext
        include Decidim::Admin::HasTrashableResources

        helper_method :current_assembly, :parent_assembly, :parent_assembly_id, :current_participatory_space

        layout "decidim/admin/assemblies"

        def index
          enforce_permission_to :read, :assembly_list
          @assemblies = filtered_collection
        end

        def new
          enforce_permission_to :create, :assembly, assembly: parent_assembly
          @form = form(AssemblyForm).instance
          @form.parent_id = params[:parent_id]
        end

        def create
          enforce_permission_to :create, :assembly, assembly: parent_assembly
          @form = form(AssemblyForm).from_params(params)

          CreateAssembly.call(@form) do
            on(:ok) do |assembly|
              flash[:notice] = I18n.t("assemblies.create.success", scope: "decidim.admin")
              redirect_to components_path(assembly)
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
          enforce_permission_to :create, :assembly, assembly: collection.find_by(id: params[:parent_id])
        end

        private

        def collection
          @collection ||= OrganizationAssemblies.new(current_user.organization).query
        end

        def trashable_deleted_resource_type
          :assembly
        end

        def trashable_deleted_resource
          @trashable_deleted_resource ||= current_assembly
        end

        def trashable_deleted_collection
          @trashable_deleted_collection = filtered_collection.only_deleted.deleted_at_desc
        end

        def current_assembly
          @current_assembly ||= collection.with_deleted.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end

        alias current_participatory_space current_assembly

        def parent_assembly
          @parent_assembly ||= collection.find_by(id: parent_assembly_id)
        end

        def parent_assembly_id
          # Return the parent_id from Ransack parameters if it exists
          return ransack_params[:parent_id_eq] if ransack_params[:parent_id_eq].present?

          # If the assembly parameter is present, return its parent_id
          return assembly_parent_id if params[:assembly].present?

          # Otherwise, return the parent_id from the params hash
          return params[:parent_id]
        end

        def assembly_parent_id
          params[:assembly][:parent_id]
        end

        def assembly_params
          { id: params[:slug] }.merge(params[:assembly].to_unsafe_h)
        end
      end
    end
  end
end
