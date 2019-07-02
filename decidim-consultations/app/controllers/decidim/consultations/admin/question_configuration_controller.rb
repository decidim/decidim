# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      class QuestionConfigurationController < Decidim::Consultations::Admin::ApplicationController
        include QuestionAdmin

        def edit
          enforce_permission_to :configure, :question, question: current_question
          p current_question.inspect
          @form = question_form.from_model(current_question, current_consultation: current_consultation)
          render layout: "decidim/admin/question"
        end

        def update
          enforce_permission_to :configure, :question, question: current_question

          @form = question_form
                  .from_params(params, question_id: current_question.id, current_consultation: current_consultation)

          UpdateQuestionConfiguration.call(current_question, @form) do
            on(:ok) do |question|
              flash[:notice] = I18n.t("questions.update.success", scope: "decidim.admin")
              redirect_to edit_question_configuration_path(question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/question"
            end
          end
        end

        def question_form
          form(QuestionConfigurationForm)
        end
      end
    end
  end
end
