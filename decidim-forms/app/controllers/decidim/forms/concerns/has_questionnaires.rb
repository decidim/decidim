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
      module HasQuestionnaires
        extend ActiveSupport::Concern

        included do
          helper Decidim::Forms::ApplicationHelper
          include FormFactory

          helper_method :questionnaire_for,
                        :questionnaire,
                        :questionnaires,
                        :allow_answers?,
                        :visitor_can_answer?,
                        :visitor_already_answered?,
                        :show_url,
                        :answer_form_url,
                        :answer_and_previous_step_url,
                        :answer_and_next_step_url,
                        :update_url

          invisible_captcha on_spam: :spam_detected

          def index
            redirect_to action: :show, id: questionnaire_for.questionnaires.first.id
          end

          def show
            @form = form(Decidim::Forms::QuestionnaireForm).from_model(questionnaire)
            render template: "decidim/forms/questionnaires/show"
          end

          # This action is used to answer a single questionnaire of a form, in
          # case a form has more than one questionnaire. In this case,
          # questionnaires are used as steps.
          #
          # This action will take the user to the previous step of the form.
          # This way users can jump between steps in a single form.
          def answer_and_previous_step
            answer_and_move_to(questionnaire.previous_step_id)
          end

          # This action is used to answer a single questionnaire of a form, in
          # case a form has more than one questionnaire. In this case,
          # questionnaires are used as steps.
          #
          # This action will take the user to the next step of the form. This
          # way users can jump between steps in a single form.
          def answer_and_next_step
            answer_and_move_to(questionnaire.next_step_id)
          end

          # This action is used to submit the answers to the whole form. After
          # this action is executed, the whole form will be considered answered
          # by the user.
          def answer_form
            enforce_permission_to :answer, :questionnaire, questionnaire: questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm)
                    .from_params(
                      params,
                      session_token: session_token,
                      in_full_form_mode: true
                    )

            handle_request(form: @form, show_success: true, after_path: after_answer_path)
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
            url_for(action: :index)
          end

          # You can implement this method in your controller to change the URL
          # where the questionnaire will be submitted.
          def update_url
            url_for(id: questionnaire.id, action: :answer_and_next_step)
          end

          # You can implement this method in your controller to change the URL
          # where the questionnaire will be submitted.
          def show_url(id:)
            url_for(action: :show, id: id)
          end

          def answer_and_next_step_url
            url_for(id: questionnaire.id, action: :answer_and_next_step)
          end

          def answer_and_previous_step_url
            url_for(id: questionnaire.id, action: :answer_and_previous_step)
          end

          def answer_form_url
            url_for(id: questionnaire.id, action: :answer_form)
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
            @questionnaire ||= questionnaires.find(params[:id])
          end

          def questionnaires
            @questionnaires ||= Questionnaire.includes(questions: :answer_options).where(questionnaire_for: questionnaire_for)
          end

          def spam_detected
            enforce_permission_to :answer, :questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm).from_params(params)

            flash.now[:alert] = I18n.t("answer.spam_detected", scope: i18n_flashes_scope)
            render template: "decidim/forms/questionnaires/show"
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

          def tokenize(id)
            Digest::MD5.hexdigest("#{id}-#{Rails.application.secrets.secret_key_base}")
          end

          def answer_and_move_to(step_id)
            enforce_permission_to :answer, :questionnaire, questionnaire: questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm)
                    .from_params(
                      params,
                      session_token: session_token
                    )

            handle_request(form: @form, after_path: show_url(id: step_id))
          end

          def handle_request(form:, show_success: false, after_path:)
            Decidim::Forms::AnswerQuestionnaire.call(form, current_user, questionnaire) do
              on(:ok) do
                # i18n-tasks-use t("decidim.forms.questionnaires.answer.success")
                flash[:notice] = I18n.t("answer.success", scope: i18n_flashes_scope) if show_success
                redirect_to after_path
              end

              on(:invalid) do
                # i18n-tasks-use t("decidim.forms.questionnaires.answer.invalid")
                flash.now[:alert] = I18n.t("answer.invalid", scope: i18n_flashes_scope)
                render template: "decidim/forms/questionnaires/show"
              end
            end
          end
        end
      end
    end
  end
end
