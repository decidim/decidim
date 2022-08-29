# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings registration forms", type: :system do
  let(:manifest_name) { "meetings" }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:meeting) { create :meeting, scope:, component: current_component, questionnaire:, registrations_enabled: true, registration_form_enabled: true }

  include_context "when managing a component as an admin"

  it_behaves_like "manage questionnaires"

  def registrations_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_registrations_path(meeting_id: meeting.id)
  end

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_registrations_form_path(meeting_id: meeting.id)
  end

  def questionnaire_public_path
    Decidim::EngineRouter.main_proxy(component).join_meeting_registration_path(meeting_id: meeting.id)
  end

  describe "manages registration form" do
    it "allows to change the custom content in registration email" do
      visit registrations_edit_path
      find("#meeting_customize_registration_email").click
      expect(page.find_all(("div[data-tabs-content*='meeting-registration_email_custom_content-tab']")).first.sibling(".help-text")).to be_present
      fill_in_i18n_editor(
        :meeting_registration_email_custom_content,
        "#meeting-registration_email_custom_content-tabs",
        en: "We're very happy you registered for this event!"
      )
    end
  end
end
