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
          enforce_permission_to :update, :debate, debate: debate

          @form = form(Decidim::Debates::Admin::DebateForm).from_model(debate)
        end

        def update
          enforce_permission_to :update, :debate, debate: debate

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
          enforce_permission_to :delete, :debate, debate: debate

          debate.destroy!

          flash[:notice] = I18n.t("debates.destroy.success", scope: "decidim.debates.admin")

          redirect_to debates_path
        end

        private

        def debates
          @debates ||= Debate.where(component: current_component)
        end

        def debate
          @debate ||= debates.find(params[:id])
        end
      end
    end
  end
end
