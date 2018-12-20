# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings registration forms", type: :system do
  let(:manifest_name) { "meetings" }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:meeting) { create :meeting, scope: scope, component: current_component, questionnaire: questionnaire, registrations_enabled: true, registration_form_enabled: true }

  include_context "when managing a component as an admin"

  it_behaves_like "manage questionnaires"

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_registrations_form_path(meeting_id: meeting.id)
  end

  def questionnaire_public_path
    Decidim::EngineRouter.main_proxy(component).join_meeting_registration_path(meeting_id: meeting.id)
  end
end
