# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      module Concerns
        # Questionnaires can be related to any class in Decidim, in order to
        # manage the questionnaires for a given type, you should create a new
        # controller and include this concern.
        #
        # The only requirement is to define a `questionnaire_for` method that
        # returns an instance of the model that questionnaire belongs to.
        module HasQuestionnaireAnswers
          extend ActiveSupport::Concern

          included do
            include Decidim::Paginable
            helper Decidim::Forms::Admin::QuestionnaireAnswersHelper

            helper_method :questionnaire_url, :questionnaire_participants_url, :questionnaire_participant_answers_url, :participant
            helper_method :prev_url, :next_url, :first?, :last?

            def index
              enforce_permission_to :index, :questionnaire_answers

              @participants = paginate(participants)

              render template: "decidim/forms/admin/questionnaires/answers/index"
            end

            def show
              enforce_permission_to :show, :questionnaire_answers

              @answers = participant_answers

              render template: "decidim/forms/admin/questionnaires/answers/show"
            end

            # Public: The only method to be implemented at the controller. You need to
            # return the object that will hold the questionnaire.
            def questionnaire_for
              raise "#{self.class.name} is expected to implement #questionnaire_for"
            end

            # You can implement this method in your controller to change the URL
            # where the questionnaire can be edited.
            def questionnaire_url
              url_for(questionnaire.questionnaire_for)
            end

            # You can implement this method in your controller to change the URL
            # where the questionnaire participants' info will be shown.
            def questionnaire_participants_url
              url_for([:index, questionnaire.questionnaire_for]) # TODO: ?
            end

            # You can implement this method in your controller to change the URL
            # where the user's questionnaire answers will be shown.
            def questionnaire_participant_answers_url(session_token)
              url_for([:show, questionnaire.questionnaire_for, session_token: session_token])
            end

            private

            def questionnaire
              @questionnaire ||= Questionnaire.find_by(questionnaire_for: questionnaire_for)
            end

            def query
              @query ||= QuestionnaireUserAnswers.new(questionnaire).query
            end

            def participant_fields
              [:session_token, :decidim_user_id, :ip_hash]
            end

            def participant_token
              params[:session_token]
            end

            def participant_ids
              participants.pluck(:session_token)
            end

            def participants
              query.select(participant_fields).distinct
            end

            def participant
              participants.find_by(session_token: participant_token)
            end

            def participant_answers
              query.where(session_token: participant_token)
            end

            # Custom pagination methods
            def current_idx
              participant_ids.index(participant_token)
            end

            def prev_url
              return if first?

              token = participant_ids[current_idx - 1]
              questionnaire_participant_answers_url(token)
            end

            def next_url
              return if last?

              token = participant_ids[current_idx + 1]
              questionnaire_participant_answers_url(token)
            end

            def first?
              current_idx.zero?
            end

            def last?
              current_idx == participant_ids.count - 1
            end
          end
        end
      end
    end
  end
end
