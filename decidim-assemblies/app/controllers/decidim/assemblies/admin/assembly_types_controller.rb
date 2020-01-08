# frozen_string_literal: true

module Decidim
  module Assemblyes
    module Admin
      # Controller used to manage the available initiative types for the current
      # organization.
      class AssemblyTypesController < Decidim::Assemblies::Admin::ApplicationController
        # GET /admin/assembly_types
        def index
          enforce_permission_to :index, :assembly_type

          @assembly_types = AssemblyTypes.for(current_organization)
        end

        # GET /admin/assembly_types/new
        def new
          enforce_permission_to :create, :assembly_type
          @form = assembly_type_form.instance
        end

        # POST /admin/assembly_types
        def create
          enforce_permission_to :create, :assembly_type
          @form = assembly_type_form.from_params(params)

          CreateAssemblyType.call(@form) do
            on(:ok) do |assembly_type|
              flash[:notice] = I18n.t("decidim.assemblies.admin.assembly_types.create.success")
              redirect_to edit_assembly_type_path(assembly_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.assemblies.admin.assembly_types.create.error")
              render :new
            end
          end
        end

        # GET /admin/assembly_types/:id/edit
        def edit
          enforce_permission_to :edit, :assembly_type, assembly_type: current_assembly_type
          @form = assembly_type_form
                  .from_model(current_assembly_type,
                              assembly_type: current_assembly_type)
        end

        # PUT /admin/assembly_types/:id
        def update
          enforce_permission_to :update, :assembly_type, assembly_type: current_assembly_type

          @form = assembly_type_form
                  .from_params(params, assembly_type: current_assembly_type)

          UpdateAssemblyType.call(current_assembly_type, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.assemblies.admin.assembly_types.update.success")
              redirect_to edit_assembly_type_path(current_assembly_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.assemblies.admin.assembly_types.update.error")
              render :edit
            end
          end
        end

        # DELETE /admin/assembly_types/:id
        def destroy
          enforce_permission_to :destroy, :assembly_type, assembly_type: current_assembly_type
          current_assembly_type.destroy!

          redirect_to assembly_types_path, flash: {
            notice: I18n.t("decidim.assemblies.admin.assembly_types.destroy.success")
          }
        end

        private

        def current_assembly_type
          @current_assembly_type ||= AssemblyType.find(params[:id])
        end

        def assembly_type_form
          form(Decidim::Assemblies::Admin::AssemblyTypeForm)
        end
      end
    end
  end
end
