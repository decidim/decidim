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

          helper_method :questionnaire_for, :questionnaire, :allow_responses?, :visitor_can_respond?, :visitor_already_responded?, :update_url, :visitor_can_edit_responses?,
                        :form_path

          invisible_captcha on_spam: :spam_detected

          def show
            @form = form(Decidim::Forms::QuestionnaireForm).from_model(questionnaire)
            render template:
          end

          # i18n-tasks-use t("decidim.forms.questionnaires.response.success")
          # i18n-tasks-use t("decidim.forms.questionnaires.response.invalid")
          def respond
            enforce_permission_to_respond_questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm).from_params(params, session_token:, ip_hash:)

            Decidim::Forms::ResponseQuestionnaire.call(@form, questionnaire, allow_editing_responses: allow_editing_responses?) do
              on(:ok) do
                flash[:notice] = I18n.t("response.success", scope: i18n_flashes_scope)
                redirect_to after_response_path
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("response.invalid", scope: i18n_flashes_scope)
                render template:
              end
            end
          end

          def template
            "decidim/forms/questionnaires/show"
          end

          # Public: Method to be implemented at the controller. You need to
          # return true if the questionnaire can receive responses
          def allow_responses?
            raise "#{self.class.name} is expected to implement #allow_responses?"
          end

          # Public: Method to be implemented at the controller if needed. You need to
          # return true if the questionnaire can receive responses by unregistered users
          def allow_unregistered?
            false
          end

          # Public: return true if the current user (if logged) can response the questionnaire
          def visitor_can_respond?
            current_user || allow_unregistered?
          end

          # Public: return true if the current user (or session visitor) can respond the questionnaire
          def visitor_already_responded?
            questionnaire.responded_by?(current_user || tokenize(session[:session_id]))
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # responding the questionnaire. By default it redirects to the questionnaire_for.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_response_path
            questionnaire_for
          end

          # You can implement this method in your controller to change the URL
          # where the questionnaire will be submitted.
          def update_url
            url_for([questionnaire_for, { action: :respond }])
          end

          # Points to the shortest path accessing the current form. This will be
          # used to detect whether a user is leaving the form with some partial
          # responses, so that we can warn them.
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

          def allow_editing_responses?
            false
          end

          def visitor_can_edit_responses?
            current_user.present? && questionnaire_for.try(:allow_editing_responses?)
          end

          def i18n_flashes_scope
            "decidim.forms.questionnaires"
          end

          def questionnaire
            @questionnaire ||= Questionnaire.includes(questions: :response_options).find_by(questionnaire_for:)
          end

          def spam_detected
            enforce_permission_to_respond_questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm).from_params(params)

            flash.now[:alert] = I18n.t("response.spam_detected", scope: i18n_flashes_scope)
            render template:
          end

          # You can implement this method in your controller to change the
          # enforce_permission_to arguments.
          def enforce_permission_to_respond_questionnaire
            enforce_permission_to :respond, :questionnaire
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
