# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper

        def meeting_organizer_picker_text(form)
          return "" if form.object.organizer.blank?
          "#{form.object.organizer.name} (@#{form.object.organizer.nickname})"
        end

        def tabs_id_for_service(service)
          "meeting_service_#{service.to_param}"
        end

        def tabs_id_for_question(question)
          "questionnaire_question_#{question.to_param}"
        end

        def tabs_id_for_question_answer_option(question, answer_option)
          "questionnaire_question_#{question.to_param}_answer_option_#{answer_option.to_param}"
        end
      end
    end
  end
end
