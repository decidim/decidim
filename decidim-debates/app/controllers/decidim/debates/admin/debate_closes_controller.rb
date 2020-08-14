# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This controller allows an admin to close debates
      class DebateClosesController < Admin::ApplicationController
        helper_method :debate

        def edit
          enforce_permission_to :close, :debate, debate: debate

          @form = form(Admin::CloseDebateForm).from_model(debate)
        end

        def update
          enforce_permission_to :close, :debate, debate: debate

          @form = form(Admin::CloseDebateForm).from_params(params)
          @form.debate = debate

          CloseDebate.call(@form) do
            on(:ok) do |_debate|
              flash[:notice] = I18n.t("debates.close.success", scope: "decidim.debates")
              redirect_to debates_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("debates.close.invalid", scope: "decidim.debates")
              render action: "edit"
            end
          end
        end

        private

        def debate
          @debate ||= Debate.where(component: current_component).find(params[:id])
        end
      end
    end
  end
end
