# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update trustees.
      class TrusteesController < Admin::ApplicationController
        helper_method :trustees, :trustee

        def new
          enforce_permission_to :create, :trustee
          @form = form(TrusteeForm).instance
        end

        def create
          enforce_permission_to :create, :trustee
          @form = form(TrusteeForm).from_params(params)

          AddUserAsTrustee.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("trustees.create.success", scope: "decidim.elections.admin")
              redirect_to trustees_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("trustees.create.invalid", scope: "decidim.elections.admin")
              render :new
            end

            on(:exists) do
              flash.now[:alert] = I18n.t("trustees.create.exists", scope: "decidim.elections.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :trustee, trustee: trustee
          @form = form(TrusteeForm).from_model(trustee)
        end

        def update
          enforce_permission_to :update, :trustee, trustee: trustee
          @form = form(TrusteeForm).from_params(params)

          UpdateTrustee.call(@form, trustee) do
            on(:ok) do
              flash[:notice] = I18n.t("trustees.update.success", scope: "decidim.elections.admin")
              redirect_to trustees_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("trustees.update.invalid", scope: "decidim.elections.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :trustee, trustee: trustee

          RemoveTrusteeFromParticipatorySpace.call(trustee, current_user, current_participatory_space) do
            on(:ok) do
              flash[:notice] = I18n.t("trustees.destroy.success", scope: "decidim.elections.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("trustees.destroy.invalid", scope: "decidim.elections.admin")
            end
          end

          redirect_to trustees_path
        end

        private

        def trustees
          trustees_space = TrusteesParticipatorySpace.where(participatory_space: current_participatory_space).includes(:trustee)
          @trustees ||= Trustee.where(trustees_participatory_spaces: trustees_space).includes([:user]).page(params[:page]).per(15)
        end

        def trustee
          @trustee ||= trustees.find_by(id: params[:id])
        end
      end
    end
  end
end
