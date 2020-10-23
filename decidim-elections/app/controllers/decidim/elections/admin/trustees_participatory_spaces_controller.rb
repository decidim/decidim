# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows to add a user as trustee, update the status and remove a
      # trustee from a participatory space.
      class TrusteesParticipatorySpacesController < Admin::ApplicationController
        helper Decidim::ApplicationHelper

        helper_method :trustees, :trustee

        def new
          enforce_permission_to :create, :trustee_participatory_space
          @form = form(TrusteesParticipatorySpaceForm).instance
        end

        def create
          enforce_permission_to :create, :trustee_participatory_space
          @form = form(TrusteesParticipatorySpaceForm).from_params(params)

          AddUserAsTrustee.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("trustees_participatory_spaces.create.success", scope: "decidim.elections.admin")
              redirect_to trustees_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("trustees_participatory_spaces.create.invalid", scope: "decidim.elections.admin")
              render action: "new"
            end

            on(:exists) do
              flash.now[:alert] = I18n.t("trustees_participatory_spaces.create.exists", scope: "decidim.elections.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :trustee_participatory_space, trustee_participatory_space: trustee_participatory_space

          UpdateTrusteeParticipatorySpace.call(trustee_participatory_space) do
            on(:ok) do |trustee|
              flash[:notice] = I18n.t("trustees_participatory_spaces.update.success", scope: "decidim.elections.admin", trustee: trustee.user.name)
            end

            on(:invalid) do |trustee|
              flash.now[:alert] = I18n.t("trustees_participatory_spaces.update.invalid", scope: "decidim.elections.admin", trustee: trustee.user.name)
            end

            redirect_to trustees_path
          end
        end

        def destroy
          enforce_permission_to :delete, :trustee_participatory_space, trustee_participatory_space: trustee_participatory_space

          RemoveTrusteeFromParticipatorySpace.call(trustee_participatory_space) do
            on(:ok) do
              flash[:notice] = I18n.t("trustees_participatory_spaces.delete.success", scope: "decidim.elections.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("trustees_participatory_spaces.delete.invalid", scope: "decidim.elections.admin")
            end
          end

          redirect_to trustees_path
        end

        private

        def trustee_participatory_space
          @trustee_participatory_space ||= TrusteesParticipatorySpace.find_by(id: params[:id])
        end

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
