# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingsPollController do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:meeting_component, participatory_space: participatory_process) }
  let(:meeting) { create(:meeting, component:) }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_space"] = participatory_process
    request.env["decidim.current_component"] = component
    sign_in user, scope: :user
  end

  describe "GET edit" do
    it "renders the form" do
      get :edit, params: { meeting_id: meeting.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "questionnaire scoping" do
    let(:other_org) { create(:organization) }
    let(:other_process) { create(:participatory_process, :with_steps, organization: other_org) }
    let(:other_component) { create(:meeting_component, participatory_space: other_process) }
    let(:other_meeting) { create(:meeting, component: other_component) }

    it "does not load questionnaire for meetings from other organizations" do
      expect do
        get :edit, params: { meeting_id: other_meeting.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
