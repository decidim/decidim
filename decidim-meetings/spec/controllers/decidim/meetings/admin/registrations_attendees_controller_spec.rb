# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::RegistrationsAttendeesController do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
  let(:meeting) { create(:meeting, :published, component: meeting_component, registrations_enabled: true) }

  before do
    meeting_component.update!(settings: meeting_component.settings.merge("registration_code_enabled" => false))
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    request.env["decidim.current_component"] = meeting_component
    sign_in user
  end

  describe "#index" do
    it "allows administrators to view registrations without registration codes" do
      get(:index, params: { meeting_id: meeting.id })

      expect(response).to have_http_status(:ok)
    end
  end
end
