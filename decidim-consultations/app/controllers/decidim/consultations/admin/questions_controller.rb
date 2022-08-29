# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      class QuestionsController < Decidim::Consultations::Admin::ApplicationController
        include QuestionAdmin
        helper ::Decidim::Admin::ResourcePermissionsHelper

        def index
          enforce_permission_to :read, :question
          @questions = collection
          render layout: "decidim/admin/consultation"
        end

        def new
          enforce_permission_to :create, :question
          @form = question_form.instance
          render layout: "decidim/admin/consultation"
        end

        def create
          enforce_permission_to :create, :question
          @form = question_form.from_params(params, current_consultation:)

          CreateQuestion.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("questions.create.success", scope: "decidim.admin")
              redirect_to consultation_questions_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.create.error", scope: "decidim.admin")
              render :new, layout: "decidim/admin/consultation"
            end
          end
        end

        def edit
          enforce_permission_to :update, :question, question: current_question
          @form = question_form.from_model(current_question, current_consultation:)
          render layout: "decidim/admin/question"
        end

        def update
          enforce_permission_to :update, :question, question: current_question

          @form = question_form
                  .from_params(params, question_id: current_question.id, current_consultation:)

          UpdateQuestion.call(current_question, @form) do
            on(:ok) do |question|
              flash[:notice] = I18n.t("questions.update.success", scope: "decidim.admin")
              redirect_to edit_question_path(question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/question"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :question, question: current_question
          current_question.destroy!

          flash[:notice] = I18n.t("questions.destroy.success", scope: "decidim.admin")

          redirect_to consultation_questions_path(current_consultation)
        end

        private

        def collection
          @collection ||= current_consultation&.questions
        end

        def question_form
          form(QuestionForm)
        end
      end
    end
  end
end
