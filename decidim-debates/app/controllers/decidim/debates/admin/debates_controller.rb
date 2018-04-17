# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This controller allows an admin to manage debates from a Participatory Space
      class DebatesController < Admin::ApplicationController
        helper_method :debates

        def new
          @form = form(Decidim::Debates::Admin::DebateForm).instance
        end

        def create
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
          authorize! :edit, debate
          @form = form(DebateForm).from_model(debate)
        end

        def update
          authorize! :edit, debate
          @form = form(DebateForm).from_params(params, current_component: current_component)

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
          authorize! :destroy, debate
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
