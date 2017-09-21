# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assemblies.
      #
      class AssembliesController < Decidim::Admin::ApplicationController
        helper_method :current_assembly

        layout "decidim/admin/assemblies"

        def index
          authorize! :index, Decidim::Assembly
          @assemblies = collection
        end

        def new
          authorize! :new, Decidim::Assembly
          @form = form(AssemblyForm).instance
        end

        def create
          authorize! :new, Decidim::Assembly
          @form = form(AssemblyForm).from_params(params)

          CreateAssembly.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies.create.success", scope: "decidim.admin")
              redirect_to assemblies_path
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
          @current_assembly ||= collection.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end

        def collection
          @collection ||= OrganizationAssemblies.new(current_user.organization).query
        end

        def ability_context
          super.merge(current_assembly: current_assembly)
        end

        def assembly_params
          {
            id: params[:id],
            hero_image: current_assembly.hero_image,
            banner_image: current_assembly.banner_image
          }.merge(params[:assembly].to_unsafe_h)
        end
      end
    end
  end
end
