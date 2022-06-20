# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller used to manage the available initiative types for the current
      # organization.
      class InitiativesTypesController < Decidim::Initiatives::Admin::ApplicationController
        helper ::Decidim::Admin::ResourcePermissionsHelper
        helper_method :current_initiative_type

        # GET /admin/initiatives_types
        def index
          enforce_permission_to :index, :initiative_type

          @initiatives_types = InitiativeTypes.for(current_organization)
        end

        # GET /admin/initiatives_types/new
        def new
          enforce_permission_to :create, :initiative_type
          @form = initiative_type_form.instance
        end

        # POST /admin/initiatives_types
        def create
          enforce_permission_to :create, :initiative_type
          @form = initiative_type_form.from_params(params)

          CreateInitiativeType.call(@form, current_user) do
            on(:ok) do |initiative_type|
              flash[:notice] = I18n.t("decidim.initiatives.admin.initiatives_types.create.success")
              redirect_to edit_initiatives_type_path(initiative_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.initiatives.admin.initiatives_types.create.error")
              render :new
            end
          end
        end

        # GET /admin/initiatives_types/:id/edit
        def edit
          enforce_permission_to :edit, :initiative_type, initiative_type: current_initiative_type
          @form = initiative_type_form
                  .from_model(current_initiative_type,
                              initiative_type: current_initiative_type)
        end

        # PUT /admin/initiatives_types/:id
        def update
          enforce_permission_to :update, :initiative_type, initiative_type: current_initiative_type

          @form = initiative_type_form
                  .from_params(params, initiative_type: current_initiative_type)

          UpdateInitiativeType.call(current_initiative_type, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.initiatives.admin.initiatives_types.update.success")
              redirect_to edit_initiatives_type_path(current_initiative_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.initiatives.admin.initiatives_types.update.error")
              render :edit
            end
          end
        end

        # DELETE /admin/initiatives_types/:id
        def destroy
          enforce_permission_to :destroy, :initiative_type, initiative_type: current_initiative_type

          Decidim.traceability.perform_action!("delete", current_initiative_type, current_user) do
            current_initiative_type.destroy!
          end

          redirect_to initiatives_types_path, flash: {
            notice: I18n.t("decidim.initiatives.admin.initiatives_types.destroy.success")
          }
        end

        private

        def current_initiative_type
          @current_initiative_type ||= InitiativesType.find(params[:id])
        end

        def initiative_type_form
          form(Decidim::Initiatives::Admin::InitiativeTypeForm)
        end
      end
    end
  end
end
