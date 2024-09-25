# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This controller allows an admin to manage debates from a Participatory Space
      class DebatesController < Decidim::Debates::Admin::ApplicationController
        helper Decidim::ApplicationHelper

        helper_method :debates, :deleted_debates

        def index
          enforce_permission_to :read, :debate
        end

        def new
          enforce_permission_to :create, :debate

          @form = form(Decidim::Debates::Admin::DebateForm).instance
        end

        def create
          enforce_permission_to :create, :debate

          @form = form(Decidim::Debates::Admin::DebateForm).from_params(params, current_component:)

          CreateDebate.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("debates.create.success", scope: "decidim.debates.admin")
              redirect_to debates_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("debates.create.invalid", scope: "decidim.debates.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to(:update, :debate, debate:)

          @form = form(Decidim::Debates::Admin::DebateForm).from_model(debate)
        end

        def update
          enforce_permission_to(:update, :debate, debate:)

          @form = form(Decidim::Debates::Admin::DebateForm).from_params(params, current_component:)

          UpdateDebate.call(@form, debate) do
            on(:ok) do
              flash[:notice] = I18n.t("debates.update.success", scope: "decidim.debates.admin")
              redirect_to debates_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("debates.update.invalid", scope: "decidim.debates.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to(:delete, :debate, debate:)

          debate.destroy!

          flash[:notice] = I18n.t("debates.destroy.success", scope: "decidim.debates.admin")

          redirect_to debates_path
        end

        def soft_delete
          enforce_permission_to(:soft_delete, :debate, debate:)

          Decidim::Commands::SoftDeleteResource.call(debate, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("debates.soft_delete.success", scope: "decidim.debates.admin")
              redirect_to debates_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("debates.soft_delete.invalid", scope: "decidim.debates.admin")
              redirect_to debates_path
            end
          end
        end

        def restore
          enforce_permission_to(:restore, :debate, debate:)

          Decidim::Commands::RestoreResource.call(debate, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("debates.restore.success", scope: "decidim.debates.admin")
              redirect_to manage_trash_debates_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("debates.restore.invalid", scope: "decidim.debates.admin")
              redirect_to manage_trash_debates_path
            end
          end
        end

        def manage_trash
          enforce_permission_to :manage_trash, :debate
        end

        private

        def debates
          @debates ||= Debate.where(component: current_component, deleted_at: nil).not_hidden
        end

        def deleted_debates
          @deleted_debates ||= Debate.where(component: current_component).trashed
        end

        def debate
          @debate ||= Debate.find_by(component: current_component, id: params[:id])
        end
      end
    end
  end
end
