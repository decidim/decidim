# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller used to manage the available initiative types for the current
      # organization.
      class InitiativesTypesController < Decidim::Initiatives::Admin::ApplicationController
        include Decidim::TranslatableAttributes

        before_action :set_controller_breadcrumb, except: [:index, :new, :create]
        before_action :set_initiative_types_with_initiatives, only: [:index]

        add_breadcrumb_item_from_menu :admin_initiatives_menu

        helper ::Decidim::Admin::ResourcePermissionsHelper
        helper_method :current_initiative_type

        # GET /admin/initiatives_types
        def index
          enforce_permission_to :index, :initiative_type

          # The destroy permission checks whether each type has initiatives through
          # its scopes. Resolving that in one batched query avoids both the N+1 and
          # loading every initiative of the organization just to know if a type has
          # any.
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

          CreateInitiativeType.call(@form) do
            on(:ok) do |initiative_type|
              flash[:notice] = I18n.t("decidim.initiatives.admin.initiatives_types.create.success")
              redirect_to edit_initiatives_type_path(initiative_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.initiatives.admin.initiatives_types.create.error")
              render :new, status: :unprocessable_content
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

          UpdateInitiativeType.call(@form, current_initiative_type) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.initiatives.admin.initiatives_types.update.success")
              redirect_to edit_initiatives_type_path(current_initiative_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.initiatives.admin.initiatives_types.update.error")
              render :edit, status: :unprocessable_content
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

        protected

        # The batched check calculated in `index` is passed to the permissions so
        # the destroy check does not query the associations for every listed type.
        # When it is not available the permission falls back to the association
        # check, which keeps the behaviour for the other actions.
        def permissions_context
          super.merge(initiative_types_with_initiatives: @initiative_types_with_initiatives)
        end

        private

        def set_initiative_types_with_initiatives
          @initiative_types_with_initiatives = InitiativeTypesWithInitiatives.for(current_organization)
        end

        def set_controller_breadcrumb
          controller_breadcrumb_items <<
            {
              label: translated_attribute(current_initiative_type.title),
              url: edit_initiatives_type_path(current_initiative_type),
              active: true
            }
        end

        def current_initiative_type
          @current_initiative_type ||= InitiativesType.where(organization: current_organization).find(params.expect(:id))
        end

        def initiative_type_form
          form(Decidim::Initiatives::Admin::InitiativeTypeForm)
        end
      end
    end
  end
end
