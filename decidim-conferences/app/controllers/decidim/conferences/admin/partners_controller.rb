# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference speakers.
      #
      class PartnersController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        def index
          enforce_permission_to :index, :partner

          @query = params[:q]

          @partners = collection.page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :create, :partner
          @form = form(Decidim::Conferences::Admin::PartnerForm).instance
        end

        def create
          enforce_permission_to :create, :partner
          @form = form(Decidim::Conferences::Admin::PartnerForm).from_params(params)

          CreatePartner.call(@form, current_user, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("partners.create.success", scope: "decidim.admin")
              redirect_to conference_partners_path(current_conference)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("partners.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @partner = collection.find(params[:id])
          enforce_permission_to :update, :partner, speaker: @partner
          @form = form(Decidim::Conferences::Admin::PartnerForm).from_model(@partner)
        end

        def update
          @partner = collection.find(params[:id])
          enforce_permission_to :update, :partner, speaker: @partner
          @form = form(Decidim::Conferences::Admin::PartnerForm).from_params(params)

          UpdatePartner.call(@form, @partner) do
            on(:ok) do
              flash[:notice] = I18n.t("partners.update.success", scope: "decidim.admin")
              redirect_to conference_partners_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("partners.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @partner = collection.find(params[:id])
          enforce_permission_to :destroy, :partner, speaker: @partner

          DestroyPartner.call(@partner, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("partners.destroy.success", scope: "decidim.admin")
              redirect_to conference_partners_path(current_conference)
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::Conferences::Partner.where(conference: current_conference)
        end
      end
    end
  end
end
