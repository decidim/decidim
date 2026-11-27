# frozen_string_literal: true

require "spec_helper"

describe "YouTube online meeting URL embedding" do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :published, organization:) }
  let(:component) { create(:meeting_component, :published, participatory_space:) }
  let(:author) { create(:user, :confirmed, organization:) }

  let(:youtube_url) { "https://www.youtube.com/watch?v=pj_2G3x6-Zk" }
  let(:online_meeting_url) { youtube_url }

  let!(:meeting) do
    create(
      :meeting,
      :published,
      :online,
      :live,
      :embed_in_meeting_page_iframe_embed_type,
      component:,
      author:,
      online_meeting_url:,
      iframe_access_level: :all
    )
  end

  let(:meeting_path) { Decidim::EngineRouter.main_proxy(component).meeting_path(meeting) }
  let(:live_event_path) { Decidim::EngineRouter.main_proxy(component).meeting_live_event_path(meeting_id: meeting.id) }

  let(:participant_form) do
    Decidim::Meetings::MeetingForm.from_params(
      title: "A meeting about the neighbourhood",
      description: "A description of the meeting for the neighbourhood.",
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      type_of_meeting: "online",
      online_meeting_url:,
      iframe_embed_type: "embed_in_meeting_page",
      iframe_access_level: "all",
      registration_type: "on_different_platform",
      registration_url: "https://decidim.org"
    ).with_context(current_organization: organization, current_component: component, current_participatory_space: participatory_space)
  end

  before { host! organization.host }

  describe "control" do
    it "accepts a normal YouTube URL in the participant form" do
      participant_form.valid?

      expect(participant_form.errors[:online_meeting_url]).to be_empty
      expect(participant_form.errors[:iframe_embed_type]).to be_empty
    end

    it "embeds the youtube-nocookie player on the live event page" do
      get live_event_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("https://www.youtube-nocookie.com/embed/pj_2G3x6-Zk")
    end
  end

  describe "security" do
    context "with an HTML payload percent-encoded in the v parameter" do
      let(:payload) { "https://www.youtube.com/watch?v=abc%22%3E%20--%3E%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E" }
      let(:online_meeting_url) { payload }

      it "the payload URL passes the participant form validations (reach)" do
        participant_form.valid?

        expect(participant_form.errors[:online_meeting_url]).to be_empty
        expect(participant_form.errors[:iframe_embed_type]).to be_empty
      end

      it "does not render the decoded markup on the live event page" do
        get live_event_path

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("<img src=x onerror=alert(1)>")
      end

      it "does not render the decoded markup on the meeting page" do
        get meeting_path

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("<img src=x onerror=alert(1)>")
      end
    end

    context "with a CSP directive percent-encoded in the v parameter" do
      let(:csp_payload) { "https://www.youtube.com/watch?v=abc%3B%20script-src%20%27unsafe-inline%27" }
      let(:online_meeting_url) { csp_payload }

      it "does not inject a new directive into the Content-Security-Policy header" do
        get meeting_path

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Security-Policy"]).not_to include("https://www.youtube-nocookie.com/embed/abc; script-src 'unsafe-inline'")
      end
    end
  end
end
