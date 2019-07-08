# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that manages responses for a question
      class ResponseGroupsController < Decidim::Consultations::Admin::ApplicationController
        include QuestionAdmin

        helper_method :current_group

        def index
          enforce_permission_to :read, :response
        end

        def new
          enforce_permission_to :create_group, :response, question: current_question
          @form = response_group_form.instance
        end

        def create
          enforce_permission_to :create_group, :response, question: current_question
          @form = response_group_form.from_params(params, current_question: current_question)

          CreateResponseGroup.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("responses.create.success", scope: "decidim.admin")
              redirect_to response_groups_path(current_question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("responses.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :create_group, :response, question: current_question
          @form = response_group_form.from_model(current_group, current_question: current_question)
        end

        def update
          enforce_permission_to :create_group, :response, question: current_question

          @form = response_group_form.from_params(params, current_question: current_question)
          UpdateResponse.call(current_group, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("responses.update.success", scope: "decidim.admin")
              redirect_to response_groups_path(current_question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("responses.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :create_group, :response, question: current_question

          current_group.destroy
          if current_group.valid?
            flash[:notice] = I18n.t("responses.destroy.success", scope: "decidim.admin")
            redirect_to response_groups_path(current_question)
          else
            flash.now[:alert] = I18n.t("responses.destroy.error", scope: "decidim.admin")
            render :edit
          end
        end

        private

        def current_group
          @current_group ||= ResponseGroup.find_by(id: params[:id])
        end

        def response_group_form
          form(ResponseGroupForm)
        end
      end
    end
  end
end
