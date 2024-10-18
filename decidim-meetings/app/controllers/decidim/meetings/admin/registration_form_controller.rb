# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage the form to be filled when an user joins the meeting
      class RegistrationFormController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaire

        def questionnaire_for
          meeting
        end

        def update_url
          meeting_registrations_form_path(meeting_id: meeting.id)
        end

        def after_update_url
          edit_meeting_registrations_path(meeting_id: meeting.id)
        end

        def public_url
          Decidim::EngineRouter.main_proxy(current_component).join_meeting_registration_path(meeting)
        end

        def edit_questions_template
          "decidim/meetings/admin/registration_form/edit_questions"
        end

        private

        def i18n_questions_flashes_scope
          "decidim.forms.admin.questionnaires"
        end

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end
      end
    end
  end
end
