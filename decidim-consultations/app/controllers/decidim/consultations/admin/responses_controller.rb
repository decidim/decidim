# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that manages responses for a question
      class ResponsesController < Decidim::Consultations::Admin::ApplicationController
        include QuestionAdmin

        helper Admin::QuestionsHelper
        helper_method :current_response

        def index
          enforce_permission_to :read, :response
        end

        def new
          enforce_permission_to :create, :response
          @form = response_form.instance
        end

        def create
          enforce_permission_to :create, :response
          @form = response_form.from_params(params, current_question:)

          CreateResponse.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("responses.create.success", scope: "decidim.admin")
              redirect_to responses_path(current_question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("responses.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :response, response: current_response
          @form = response_form.from_model(current_response, current_question:)
        end

        def update
          enforce_permission_to :update, :response, response: current_response

          @form = response_form.from_params(params, current_question:)
          UpdateResponse.call(current_response, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("responses.update.success", scope: "decidim.admin")
              redirect_to responses_path(current_question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("responses.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :response, response: current_response

          current_response.destroy
          if current_response.valid?
            flash[:notice] = I18n.t("responses.destroy.success", scope: "decidim.admin")
            redirect_to responses_path(current_question)
          else
            flash.now[:alert] = I18n.t("responses.destroy.error", scope: "decidim.admin")
            render :edit
          end
        end

        private

        def current_response
          @current_response ||= Response.find_by(id: params[:id])
        end

        def response_form
          form(ResponseForm)
        end
      end
    end
  end
end
