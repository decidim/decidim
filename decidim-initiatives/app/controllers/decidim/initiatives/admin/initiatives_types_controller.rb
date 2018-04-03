# frozen_string_literal: true

require_dependency "decidim/initiatives/admin/application_controller"

module Decidim
  module Initiatives
    module Admin
      # Controller used to manage the available initiative types for the current
      # organization.
      class InitiativesTypesController < ApplicationController
        helper_method :current_initiative_type

        # GET /admin/initiatives_types
        def index
          authorize! :index, Decidim::InitiativesType

          @initiatives_types = InitiativeTypes.for(current_organization)
        end

        # GET /admin/initiatives_types/new
        def new
          authorize! :new, Decidim::InitiativesType
          @form = initiative_type_form.instance
        end

        # POST /admin/initiatives_types
        def create
          authorize! :create, Decidim::InitiativesType
          @form = initiative_type_form.from_params(params)

          CreateInitiativeType.call(@form) do
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
          authorize! :edit, current_initiative_type
          @form = initiative_type_form
                  .from_model(current_initiative_type,
                              initiative_type: current_initiative_type)
        end

        # PUT /admin/initiatives_types/:id
        def update
          authorize! :update, current_initiative_type

          @form = initiative_type_form
                  .from_params(params, initiative_type: current_initiative_type)

          UpdateInitiativeType.call(current_initiative_type, @form) do
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
          authorize! :destroy, current_initiative_type
          current_initiative_type.destroy!

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
