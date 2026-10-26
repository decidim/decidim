# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::LiveEventsController do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:meeting_component, participatory_space:) }
  let(:meeting) do
    create(
      :meeting,
      :published,
      :online,
      component:,
      start_time: 5.minutes.ago,
      end_time: 1.hour.from_now
    )
  end

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_space"] = participatory_space
    request.env["decidim.current_component"] = component
  end

  describe "GET show" do
    context "when the meeting is visible" do
      it "renders the live event" do
        get :show, params: { meeting_id: meeting.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the meeting does not exist" do
      it "returns a 404 status" do
        expect { get :show, params: { meeting_id: "non-existent" } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
