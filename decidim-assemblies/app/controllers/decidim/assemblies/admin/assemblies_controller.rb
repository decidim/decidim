# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assemblies.
      #
      class AssembliesController < Decidim::Admin::ApplicationController
        helper_method :current_assembly, :parent_assembly, :parent_assemblies, :current_participatory_space
        layout "decidim/admin/assemblies"

        def index
          authorize! :index, Decidim::Assembly
          @assemblies = collection
        end

        def new
          authorize! :new, Decidim::Assembly
          @form = form(AssemblyForm).instance
          @form.parent_id = params[:parent_id]
        end

        def create
          authorize! :new, Decidim::Assembly
          @form = form(AssemblyForm).from_params(params)

          CreateAssembly.call(@form) do
            on(:ok) do |assembly|
              flash[:notice] = I18n.t("assemblies.create.success", scope: "decidim.admin")
              redirect_to assemblies_path(parent_id: assembly.parent_id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          authorize! :update, current_assembly
          @form = form(AssemblyForm).from_model(current_assembly)
          render layout: "decidim/admin/assembly"
        end

        def update
          authorize! :update, current_assembly
          @form = form(AssemblyForm).from_params(
            assembly_params,
            assembly_id: current_assembly.id
          )

          UpdateAssembly.call(current_assembly, @form) do
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

        def destroy
          authorize! :destroy, current_assembly
          current_assembly.destroy!

          flash[:notice] = I18n.t("assemblies.destroy.success", scope: "decidim.admin")

          redirect_to assemblies_path
        end

        def copy
          authorize! :create, Decidim::Assembly
        end

        private

        def current_assembly
          scope = OrganizationAssemblies.new(current_user.organization).query
          @current_assembly ||= scope.where(slug: params[:slug]).or(
            scope.where(id: params[:slug])
          ).first
        end

        alias current_participatory_space current_assembly

        def parent_assembly
          @parent_assembly ||= OrganizationAssemblies.new(current_organization).query.find_by(id: params[:parent_id])
        end

        def parent_assemblies
          @parent_assemblies ||= OrganizationAssemblies.new(current_user.organization).query.where(parent_id: nil)
        end

        def collection
          parent_id = params[:parent_id].presence
          @collection ||= OrganizationAssemblies.new(current_user.organization).query.where(parent_id: parent_id)
        end

        def ability_context
          super.merge(current_participatory_space: current_assembly)
        end

        def assembly_params
          {
            id: params[:slug],
            hero_image: current_assembly.hero_image,
            banner_image: current_assembly.banner_image
          }.merge(params[:assembly].to_unsafe_h)
        end
      end
    end
  end
end
