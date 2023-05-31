# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that manages responses for a question
      class ResponseGroupsController < Decidim::Consultations::Admin::ApplicationController
        include QuestionAdmin

        helper_method :current_response_group

        def index
          enforce_permission_to :read, :response_group, question: current_question
        end

        def new
          enforce_permission_to :create, :response_group, question: current_question
          @form = response_group_form.instance
        end

        def create
          enforce_permission_to :create, :response_group, question: current_question
          @form = response_group_form.from_params(params, current_question:)

          CreateResponseGroup.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("response_groups.create.success", scope: "decidim.admin")
              redirect_to response_groups_path(current_question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("response_groups.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :response_group, response_group: current_response_group
          @form = response_group_form.from_model(current_response_group)
        end

        def update
          enforce_permission_to :update, :response_group, response_group: current_response_group

          @form = response_group_form.from_params(params)
          UpdateResponseGroup.call(current_response_group, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("response_groups.update.success", scope: "decidim.admin")
              redirect_to response_groups_path(current_question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("response_groups.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :response_group, response_group: current_response_group

          DestroyResponseGroup.call(current_response_group) do
            on(:ok) do
              flash[:notice] = I18n.t("response_groups.destroy.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("response_groups.destroy.error", scope: "decidim.admin")
            end

            redirect_to response_groups_path(current_question)
          end
        end

        private

        def current_response_group
          @current_response_group ||= ResponseGroup.find_by(id: params[:id])
        end

        def response_group_form
          form(ResponseGroupForm)
        end
      end
    end
  end
end
