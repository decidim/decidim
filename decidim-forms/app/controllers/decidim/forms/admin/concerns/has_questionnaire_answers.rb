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

            helper_method :questionnaire_url, :questionnaire_participants_url, :questionnaire_participant_answers_url, :questionnaire_export_url, :questionnaire_export_response_url
            helper_method :prev_url, :next_url, :first?, :last?

            def index
              enforce_permission_to :index, :questionnaire_answers

              @query = paginate(collection)
              @participants = participants(@query)

              render template: "decidim/forms/admin/questionnaires/answers/index"
            end

            def show
              enforce_permission_to :show, :questionnaire_answers

              @participant = participant

              render template: "decidim/forms/admin/questionnaires/answers/show"
            end

            def export
              enforce_permission_to :export, :questionnaire_answers

              @participants = participants(collection)

              render pdf: "#{questionnaire.id}_responses",
                     template: "decidim/forms/admin/questionnaires/answers/export/pdf.html.erb",
                     layout: "decidim/forms/admin/questionnaires/questionnaire_answers.html.erb"
            end

            def export_response
              enforce_permission_to :export_response, :questionnaire_answers

              @participants = [participant]

              render pdf: "#{questionnaire.id}_response_#{participant.session_token}",
                     template: "decidim/forms/admin/questionnaires/answers/export/pdf.html.erb",
                     layout: "decidim/forms/admin/questionnaires/questionnaire_answers.html.erb"
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

            def questionnaire_export_url
              url_for([:export, questionnaire.questionnaire_for])
            end

            def questionnaire_export_response_url(session_token)
              url_for([:export_response, questionnaire.questionnaire_for, session_token: session_token])
            end

            private

            def questionnaire
              @questionnaire ||= Questionnaire.find_by(questionnaire_for: questionnaire_for)
            end

            def collection
              @collection ||= QuestionnaireParticipants.new(questionnaire).query
            end

            def participant(session_token = nil)
              session_token ||= params[:session_token]
              Decidim::Forms::Admin::QuestionnaireParticipantPresenter.new(questionnaire: questionnaire, session_token: session_token)
            end

            def participants(query)
              query.map { |p| participant(p.session_token) }
            end

            # Custom pagination methods
            def participant_ids
              @participant_ids ||= collection.pluck(:session_token)
            end

            def current_idx
              participant_ids.index(params[:session_token])
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
