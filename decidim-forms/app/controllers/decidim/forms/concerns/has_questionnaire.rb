# frozen_string_literal: true

module Decidim
  module Forms
    module Concerns
      # Questionnaires can be related to any class in Decidim, in order to
      # manage the questionnaires for a given type, you should create a new
      # controller and include this concern.
      #
      # The only requirement is to define a `questionnaire_for` method that
      # returns an instance of the model that questionnaire belongs to.
      module HasQuestionnaire
        extend ActiveSupport::Concern

        included do
          helper Decidim::Forms::ApplicationHelper
          include FormFactory

          helper_method :questionnaire_for, :questionnaire, :allow_answers?, :visitor_can_answer?, :visitor_already_answered?, :update_url, :form_path

          invisible_captcha on_spam: :spam_detected

          def show
            @form = form(Decidim::Forms::QuestionnaireForm).from_model(questionnaire)
            render template: "decidim/forms/questionnaires/show"
          end

          def answer
            enforce_permission_to_answer_questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm).from_params(params, session_token:, ip_hash:)

            Decidim::Forms::AnswerQuestionnaire.call(@form, current_user, questionnaire) do
              on(:ok) do
                # i18n-tasks-use t("decidim.forms.questionnaires.answer.success")
                flash[:notice] = I18n.t("answer.success", scope: i18n_flashes_scope)
                redirect_to after_answer_path
              end

              on(:invalid) do
                # i18n-tasks-use t("decidim.forms.questionnaires.answer.invalid")
                flash.now[:alert] = I18n.t("answer.invalid", scope: i18n_flashes_scope)
                render template: "decidim/forms/questionnaires/show"
              end
            end
          end

          # Public: Method to be implemented at the controller. You need to
          # return true if the questionnaire can receive answers
          def allow_answers?
            raise "#{self.class.name} is expected to implement #allow_answers?"
          end

          # Public: Method to be implemented at the controller if needed. You need to
          # return true if the questionnaire can receive answers by unregistered users
          def allow_unregistered?
            false
          end

          # Public: return true if the current user (if logged) can answer the questionnaire
          def visitor_can_answer?
            current_user || allow_unregistered?
          end

          # Public: return true if the current user (or session visitor) can answer the questionnaire
          def visitor_already_answered?
            questionnaire.answered_by?(current_user || tokenize(session[:session_id]))
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # answering the questionnaire. By default it redirects to the questionnaire_for.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_answer_path
            questionnaire_for
          end

          # You can implement this method in your controller to change the URL
          # where the questionnaire will be submitted.
          def update_url
            url_for([questionnaire_for, { action: :answer }])
          end

          # Points to the shortest path accessing the current form. This will be
          # used to detect whether a user is leaving the form with some partial
          # answers, so that we can warn them.
          #
          # Overwrite this method at the controller.
          def form_path
            url_for([questionnaire_for, { only_path: true }])
          end

          # Public: Method to be implemented at the controller. You need to
          # return the object that will hold the questionnaire.
          def questionnaire_for
            raise "#{self.class.name} is expected to implement #questionnaire_for"
          end

          private

          def i18n_flashes_scope
            "decidim.forms.questionnaires"
          end

          def questionnaire
            @questionnaire ||= Questionnaire.includes(questions: :answer_options).find_by(questionnaire_for:)
          end

          def spam_detected
            enforce_permission_to_answer_questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm).from_params(params)

            flash.now[:alert] = I18n.t("answer.spam_detected", scope: i18n_flashes_scope)
            render template: "decidim/forms/questionnaires/show"
          end

          # You can implement this method in your controller to change the
          # enforce_permission_to arguments.
          def enforce_permission_to_answer_questionnaire
            enforce_permission_to :answer, :questionnaire
          end

          def ip_hash
            return nil unless request&.remote_ip

            @ip_hash ||= tokenize(request&.remote_ip)
          end

          # token is used as a substitute of user_id if unregistered
          def session_token
            id = current_user&.id
            session_id = request.session[:session_id] if request&.session

            return nil unless id || session_id

            @session_token ||= tokenize(id || session_id)
          end

          def tokenize(id, length: 10)
            tokenizer = Decidim::Tokenizer.new(salt: questionnaire.salt || questionnaire.id, length:)
            tokenizer.int_digest(id).to_s
          end
        end
      end
    end
  end
end
