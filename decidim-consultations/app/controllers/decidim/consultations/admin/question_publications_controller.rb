# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing question publications.
      class QuestionPublicationsController < Decidim::Consultations::Admin::ApplicationController
        include QuestionAdmin

        def create
          enforce_permission_to :publish, :question, question: current_question

          PublishQuestion.call(current_question, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("question_publications.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("question_publications.create.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: consultation_questions_path(current_consultation))
          end
        end

        def destroy
          enforce_permission_to :publish, :question, question: current_question

          UnpublishConsultation.call(current_question) do
            on(:ok) do
              flash[:notice] = I18n.t("question_publications.destroy.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("question_publications.destroy.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: consultation_questions_path(current_consultation))
          end
        end
      end
    end
  end
end
