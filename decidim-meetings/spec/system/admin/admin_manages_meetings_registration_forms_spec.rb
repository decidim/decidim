# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings registration forms" do
  let(:manifest_name) { "meetings" }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:meeting) { create(:meeting, scope:, component: current_component, questionnaire:, registrations_enabled: true, registration_form_enabled: true) }

  before do
    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
  end

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

      expect(page).to have_content "This text will appear in the middle of the registration confirmation email"
      fill_in_i18n_editor(
        :meeting_registration_email_custom_content,
        "#meeting-registration_email_custom_content-tabs",
        en: "We are very happy you registered for this event!"
      )
    end
  end
end
