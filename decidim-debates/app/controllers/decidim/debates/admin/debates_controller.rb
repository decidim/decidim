# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This controller allows an admin to manage debates from a Participatory Space
      class DebatesController < Decidim::Debates::Admin::ApplicationController
        helper Decidim::ApplicationHelper

        helper_method :debates

        def index
          enforce_permission_to :read, :debate
        end

        def new
          enforce_permission_to :create, :debate

          @form = form(Decidim::Debates::Admin::DebateForm).instance
        end

        def create
          enforce_permission_to :create, :debate

          @form = form(Decidim::Debates::Admin::DebateForm).from_params(params, current_component: current_component)

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
          enforce_permission_to :update, :debate, debate: debate

          @form = form(Decidim::Debates::Admin::DebateForm).from_model(debate)
        end

        def update
          enforce_permission_to :update, :debate, debate: debate

          @form = form(Decidim::Debates::Admin::DebateForm).from_params(params, current_component: current_component)

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

        def archive
          enforce_permission_to :archive, :debate, debate: debate

          archive = params[:archive] == "true"

          ArchiveDebate.call(archive, debate, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("debates.#{archive ? "archive" : "unarchive"}.success", scope: "decidim.debates.admin")
              redirect_to debates_path(archive ? {} : { filter: "archive" })
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("debates.#{archive ? "archive" : "unarchive"}.invalid", scope: "decidim.debates.admin")
              redirect_to debates_path(archive ? {} : { filter: "archive" })
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :debate, debate: debate

          debate.destroy!

          flash[:notice] = I18n.t("debates.destroy.success", scope: "decidim.debates.admin")

          redirect_to debates_path
        end

        private

        def debates
          @debates ||= archive? ? all_debates.archived : all_debates.not_archived
        end

        def debate
          @debate ||= all_debates.find(params[:id])
        end

        def all_debates
          Debate.where(component: current_component)
        end

        def archive?
          params[:filter] == "archive"
        end
      end
    end
  end
end
