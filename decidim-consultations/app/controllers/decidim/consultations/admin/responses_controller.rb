# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that manages responses for a question
      class ResponsesController < Decidim::Admin::ApplicationController
        include QuestionAdmin

        helper_method :current_response

        def index
          authorize! :index, Decidim::Consultations::Response
        end

        def new
          authorize! :create, Decidim::Consultations::Response
          @form = response_form.instance
        end

        def create
          authorize! :create, Decidim::Consultations::Response
          @form = response_form.from_params(params, current_question: current_question)

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
          authorize! :update, current_response
          @form = response_form.from_model(current_response, current_question: current_question)
        end

        def update
          authorize! :update, current_response

          @form = response_form.from_params(params, current_question: current_question)
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
          authorize! :destroy, current_response

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
          @response ||= Response.find_by(id: params[:id])
        end

        def response_form
          form(ResponseForm)
        end
      end
    end
  end
end
