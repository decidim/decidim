# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::LiveEventsController do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:meeting_component, participatory_space:) }
  let(:online_meeting_url) { "https://decidim.org" }
  let(:meeting) do
    create(
      :meeting,
      :published,
      :online,
      component:,
      start_time: 5.minutes.ago,
      end_time: 1.hour.from_now,
      online_meeting_url:
    )
  end

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_space"] = participatory_space
    request.env["decidim.current_component"] = component
  end

  describe "GET show" do
    context "when the meeting is online and its host is an embeddable service" do
      let(:online_meeting_url) { "https://stream.example.org/live" }
      let(:frame_src) { response.headers["Content-Security-Policy"][/frame-src [^;]+/] }

      before do
        allow(Decidim::Meetings).to receive(:embeddable_services).and_return(["stream.example.org"])
      end

      it "does not add the embeddable service host to the frame-src directive" do
        get :show, params: { meeting_id: meeting.id }

        expect(frame_src).not_to include("stream.example.org")
      end

      context "when the host is allowed in the organization's content security policy" do
        before do
          organization.update!(
            content_security_policy: organization.content_security_policy.merge(
              "frame-src" => "#{organization.content_security_policy["frame-src"]} https://stream.example.org"
            )
          )
        end

        it "keeps the host in the frame-src directive" do
          get :show, params: { meeting_id: meeting.id }

          expect(frame_src).to include("https://stream.example.org")
        end
      end
    end

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
