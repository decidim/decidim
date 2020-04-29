# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assemblies.
      #
      class AssembliesController < Decidim::Assemblies::Admin::ApplicationController
        include Decidim::Assemblies::Admin::Filterable
        helper_method :current_assembly, :parent_assembly, :current_participatory_space
        layout "decidim/admin/assemblies"

        def index
          enforce_permission_to :read, :assembly_list
          @assemblies = filtered_collection
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

        def copy
          enforce_permission_to :create, :assembly
        end

        private

        def collection
          @collection ||= OrganizationAssemblies.new(current_user.organization).query
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
