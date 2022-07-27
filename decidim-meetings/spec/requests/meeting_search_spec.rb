# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Meeting search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create :meeting_component }
  let(:user) { create :user, :confirmed, organization: }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }

  let!(:meeting1) do
    create(
      :meeting,
      :published,
      author: user,
      component:,
      start_time: 1.day.from_now,
      description: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt.")
    )
  end
  let!(:meeting2) do
    create(
      :meeting,
      :published,
      component:,
      start_time: 1.day.ago,
      end_time: 2.days.from_now,
      description: Decidim::Faker::Localized.literal("Curabitur arcu erat, accumsan id imperdiet et.")
    )
  end
  # Meeting not published, shouldn't appear
  let!(:meeting3) do
    create(
      :meeting,
      author: user,
      component:,
      start_time: 1.day.from_now,
      description: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt.")
    )
  end
  # Meeting withdrawn, shouldn't appear
  let!(:meeting4) do
    create(
      :meeting,
      :published,
      :withdrawn,
      author: user,
      component:,
      start_time: 1.day.ago,
      end_time: 2.days.from_now,
      description: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt.")
    )
  end

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).meetings_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :published_meeting
  it_behaves_like "a resource search with scopes", :published_meeting
  it_behaves_like "a resource search with categories", :published_meeting
  it_behaves_like "a resource search with origin", :published_meeting

  it "displays all meetings without any filters" do
    expect(subject).to include(translated(meeting1.title))
    expect(subject).to include(translated(meeting2.title))
    expect(subject).not_to include(translated(meeting3.title))
    expect(subject).not_to include(translated(meeting4.title))
  end

  context "when searching by date" do
    let(:filter_params) { { with_any_date: date } }
    let!(:past_meeting) do
      create(:meeting, :published, component:, start_time: 10.days.ago, end_time: 1.day.ago)
    end

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    context "and date is upcoming" do
      let(:date) { ["upcoming"] }

      it "only returns that are scheduled in the future" do
        expect(subject).to include(translated(meeting1.title))
        expect(subject).to include(translated(meeting2.title))
        expect(subject).not_to include(translated(meeting3.title))
        expect(subject).not_to include(translated(meeting4.title))
        expect(subject).not_to include(translated(past_meeting.title))
      end
    end

    context "and date is past" do
      let(:date) { ["past"] }

      it "only returns meetings that were scheduled in the past" do
        expect(subject).not_to include(translated(meeting1.title))
        expect(subject).not_to include(translated(meeting2.title))
        expect(subject).not_to include(translated(meeting3.title))
        expect(subject).not_to include(translated(meeting4.title))
        expect(subject).to include(translated(past_meeting.title))
      end
    end
  end

  context "when searching by availability" do
    let(:filter_params) { { with_availability: availability } }

    context "and availability is withdrawn" do
      let(:availability) { "withdrawn" }

      it "only returns meetings that are withdrawn" do
        expect(subject).not_to include(translated(meeting1.title))
        expect(subject).not_to include(translated(meeting2.title))
        expect(subject).not_to include(translated(meeting3.title))
        expect(subject).to include(translated(meeting4.title))
      end
    end

    context "and availability is not set" do
      let(:availability) { nil }

      it "only returns meetings that are not withdrawn" do
        expect(subject).to include(translated(meeting1.title))
        expect(subject).to include(translated(meeting2.title))
        expect(subject).not_to include(translated(meeting3.title))
        expect(subject).not_to include(translated(meeting4.title))
      end
    end
  end

  context "when searching by text" do
    let(:filter_params) { { search_text_cont: "TestCheck" } }

    it "show only the meeting containing the search_text" do
      expect(subject).to include(translated(meeting1.title))
      expect(subject).not_to include(translated(meeting2.title))
      expect(subject).not_to include(translated(meeting3.title))
      expect(subject).not_to include(translated(meeting4.title))
    end
  end

  context "when searching by type" do
    let!(:in_person_meeting) do
      create(:meeting, :published, component:)
    end
    let!(:online_meeting) do
      create(:meeting, :published, :online, component:)
    end
    let(:filter_params) { { with_any_type: type } }

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    context "and type is online" do
      let(:type) { ["online"] }

      it "only lists online meetings" do
        expect(subject).to include(translated(online_meeting.title))
        expect(subject).not_to include(translated(in_person_meeting.title))
      end
    end

    context "and type is in_person" do
      let(:type) { ["in_person"] }

      it "only lists online meetings" do
        expect(subject).to include(translated(in_person_meeting.title))
        expect(subject).not_to include(translated(online_meeting.title))
      end
    end
  end

  context "when searching by activity" do
    let(:filter_params) { { activity: } }

    before do
      login_as user, scope: :user

      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    context "and activity is 'all'" do
      let(:activity) { "all" }

      it "returns all the meetings" do
        expect(subject).to include(translated(meeting1.title))
        expect(subject).to include(translated(meeting2.title))
      end
    end

    context "and activity is 'my meetings'" do
      let(:activity) { "my_meetings" }

      it "returns only the meeting created by the current user" do
        expect(subject).to include(translated(meeting1.title))
        expect(subject).not_to include(translated(meeting2.title))
      end
    end
  end
end
