# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference speakers.
      #
      class RegistrationTypesController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::ApplicationHelper
        include Decidim::Paginable

        def index
          enforce_permission_to :index, :registration_type

          @registration_types = paginate(collection)
        end

        def new
          enforce_permission_to :create, :registration_type
          @form = form(Decidim::Conferences::Admin::RegistrationTypeForm).instance
        end

        def create
          enforce_permission_to :create, :registration_type
          @form = form(Decidim::Conferences::Admin::RegistrationTypeForm).from_params(params)

          CreateRegistrationType.call(@form, current_user, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("registration_types.create.success", scope: "decidim.admin")
              redirect_to conference_registration_types_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registration_types.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @registration_type = collection.find(params[:id])
          enforce_permission_to :update, :registration_type, registration_type: @registration_type
          @form = form(Decidim::Conferences::Admin::RegistrationTypeForm).from_model(@registration_type)
        end

        def update
          @registration_type = collection.find(params[:id])
          enforce_permission_to :update, :registration_type, registration_type: @registration_type
          @form = form(Decidim::Conferences::Admin::RegistrationTypeForm).from_params(params)

          UpdateRegistrationType.call(@form, @registration_type) do
            on(:ok) do
              flash[:notice] = I18n.t("registration_types.update.success", scope: "decidim.admin")
              redirect_to conference_registration_types_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registration_types.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @registration_type = collection.find(params[:id])
          enforce_permission_to :destroy, :registration_type, registration_type: @registration_type

          DestroyRegistrationType.call(@registration_type, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("registration_types.destroy.success", scope: "decidim.admin")
              redirect_to conference_registration_types_path(current_conference)
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::Conferences::RegistrationType.where(conference: current_conference)
        end
      end
    end
  end
end
