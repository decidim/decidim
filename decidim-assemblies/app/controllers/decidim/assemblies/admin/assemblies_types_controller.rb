# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller used to manage the available assemblies types for the current
      # organization.
      class AssembliesTypesController < Decidim::Assemblies::Admin::ApplicationController
        helper_method :available_assemblies_types, :current_assembly_type
        layout "decidim/admin/assemblies"

        # GET /admin/assemblies_types
        def index
          enforce_permission_to :index, :assembly_type
        end

        # GET /admin/assemblies_types/new
        def new
          enforce_permission_to :create, :assembly_type
          @form = assembly_type_form.instance
        end

        # POST /admin/assemblies_types
        def create
          enforce_permission_to :create, :assembly_type
          @form = assembly_type_form.from_params(params)

          CreateAssembliesType.call(@form) do
            on(:ok) do |_assembly_type|
              flash[:notice] = I18n.t("assemblies_types.create.success", scope: "decidim.admin")
              redirect_to assemblies_types_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies_types.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        # GET /admin/assemblies_types/:id/edit
        def edit
          enforce_permission_to :edit, :assembly_type, assembly_type: current_assembly_type
          @form = assembly_type_form
                  .from_model(current_assembly_type,
                              assembly_type: current_assembly_type)
        end

        # PUT /admin/assemblies_types/:id
        def update
          enforce_permission_to :update, :assembly_type, assembly_type: current_assembly_type

          @form = assembly_type_form
                  .from_params(params, assembly_type: current_assembly_type)

          UpdateAssembliesType.call(current_assembly_type, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies_types.update.success", scope: "decidim.admin")
              redirect_to assemblies_types_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies_types.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        # DELETE /admin/assemblies_types/:id
        def destroy
          enforce_permission_to :destroy, :assembly_type, assembly_type: current_assembly_type
          current_assembly_type.destroy!

          redirect_to assemblies_types_path, flash: {
            notice: I18n.t("assemblies_types.destroy.success", scope: "decidim.admin")
          }
        end

        private

        def available_assemblies_types
          @available_assemblies_types ||= AssembliesType.where(organization: current_organization)
        end

        def current_assembly_type
          @current_assembly_type ||= AssembliesType.find(params[:id])
        end

        def assembly_type_form
          form(Decidim::Assemblies::Admin::AssembliesTypeForm)
        end
      end
    end
  end
end
