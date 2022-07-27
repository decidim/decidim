# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      class QuestionConfigurationController < Decidim::Consultations::Admin::ApplicationController
        include QuestionAdmin

        before_action :check_external_voting

        def edit
          enforce_permission_to :configure, :question, question: current_question
          @form = question_form.from_model(current_question, current_consultation:)
          render layout: "decidim/admin/question"
        end

        def update
          enforce_permission_to :configure, :question, question: current_question

          @form = question_form
                  .from_params(params, question_id: current_question.id, current_consultation:)

          UpdateQuestionConfiguration.call(current_question, @form) do
            on(:ok) do |question|
              flash[:notice] = I18n.t("questions.update.success", scope: "decidim.admin")
              redirect_to edit_question_configuration_path(question)
            end

            on(:invalid) do |_question, error|
              flash[:error] = I18n.t("questions.update.error", scope: "decidim.admin")
              flash[:error] << " (#{error})" if error
              render :edit, layout: "decidim/admin/question"
            end
          end
        end

        private

        def question_form
          form(QuestionConfigurationForm)
        end

        # This is checked here (and not in permissions) to warn the user
        # specifically about disabling external voting before using multivote questions
        def check_external_voting
          return unless current_question.external_voting

          flash[:alert] = I18n.t("question_configuration.disable_external_voting", scope: "decidim.admin")
          redirect_to edit_question_path(current_question)
        end
      end
    end
  end
end
