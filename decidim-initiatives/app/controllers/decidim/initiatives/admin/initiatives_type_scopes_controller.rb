# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller used to manage the available initiative type scopes
      class InitiativesTypeScopesController < Decidim::Initiatives::Admin::ApplicationController
        helper_method :current_initiative_type_scope

        # GET /admin/initiatives_types/:initiatives_type_id/initiatives_type_scopes/new
        def new
          authorize! :new, Decidim::InitiativesTypeScope
          @form = initiative_type_scope_form.instance
        end

        # POST /admin/initiatives_types/:initiatives_type_id/initiatives_type_scopes
        def create
          authorize! :create, Decidim::InitiativesTypeScope
          @form = initiative_type_scope_form
                  .from_params(params, type_id: params[:initiatives_type_id])

          CreateInitiativeTypeScope.call(@form) do
            on(:ok) do |initiative_type_scope|
              flash[:notice] = I18n.t("decidim.initiatives.admin.initiatives_type_scopes.create.success")
              redirect_to edit_initiatives_type_path(initiative_type_scope.type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.initiatives.admin.initiatives_type_scopes.create.error")
              render :new
            end
          end
        end

        # GET /admin/initiatives_types/:initiatives_type_id/initiatives_type_scopes/:id/edit
        def edit
          authorize! :edit, current_initiative_type_scope
          @form = initiative_type_scope_form.from_model(current_initiative_type_scope)
        end

        # PUT /admin/initiatives_types/:initiatives_type_id/initiatives_type_scopes/:id
        def update
          authorize! :update, current_initiative_type_scope
          @form = initiative_type_scope_form.from_params(params)

          UpdateInitiativeTypeScope.call(current_initiative_type_scope, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.initiatives.admin.initiatives_type_scopes.update.success")
              redirect_to edit_initiatives_type_path(initiative_type_scope.type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.initiatives.admin.initiatives_type_scopes.update.error")
              render :edit
            end
          end
        end

        # DELETE /admin/initiatives_types/:initiatives_type_id/initiatives_type_scopes/:id
        def destroy
          authorize! :destroy, current_initiative_type_scope
          current_initiative_type_scope.destroy!

          redirect_to edit_initiatives_type_path(current_initiative_type_scope.type), flash: {
            notice: I18n.t("decidim.initiatives.admin.initiatives_type_scopes.destroy.success")
          }
        end

        private

        def current_initiative_type_scope
          @current_initiative_type_scope ||= InitiativesTypeScope.find(params[:id])
        end

        def initiative_type_scope_form
          form(Decidim::Initiatives::Admin::InitiativeTypeScopeForm)
        end
      end
    end
  end
end
