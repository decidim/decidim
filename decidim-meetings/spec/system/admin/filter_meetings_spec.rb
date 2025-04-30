# frozen_string_literal: true

require "spec_helper"
describe "Admin filters meetings" do
  include_context "with filterable context"

  let(:manifest_name) { "meetings" }
  let(:model_name) { Decidim::Meetings::Meeting.model_name }
  let(:resource_controller) { Decidim::Meetings::Admin::MeetingsController }
  let!(:meeting) { create(:meeting, scope:, component:) }

  include_context "when managing a component as an admin"

  TYPES = Decidim::Meetings::Meeting::TYPE_OF_MEETING.keys

  def create_meeting_with_trait(trait)
    create(:meeting, trait, component:)
  end

  def meeting_with_type(type)
    Decidim::Meetings::Meeting.where(component:).find_by(type_of_meeting: type)
  end

  def meeting_without_type(type)
    Decidim::Meetings::Meeting.where(component:).where.not(type_of_meeting: type).sample
  end

  context "when filtering by type" do
    let!(:meetings) do
      TYPES.map { |state| create_meeting_with_trait(state) }
    end

    before { visit_component_admin }

    TYPES.each do |state|
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.meetings.with_any_type.values")

      context "when filtering meetings by type: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "Type", filter: i18n_state do
          let(:in_filter) { translated(meeting_with_type(state).title) }
          let(:not_in_filter) { translated(meeting_without_type(state).title) }
        end
      end
    end
  end

  it_behaves_like "a collection filtered by taxonomies" do
    let!(:meeting_with_taxonomy11) { create(:meeting, component:, taxonomies: [taxonomy11]) }
    let!(:meeting_with_taxonomy12) { create(:meeting, component:, taxonomies: [taxonomy12]) }
    let!(:meeting_with_taxonomy21) { create(:meeting, component:, taxonomies: [taxonomy21]) }
    let!(:meeting_with_taxonomy22) { create(:meeting, component:, taxonomies: [taxonomy22]) }
    let(:resource_with_taxonomy11_title) { translated(meeting_with_taxonomy11.title) }
    let(:resource_with_taxonomy12_title) { translated(meeting_with_taxonomy12.title) }
    let(:resource_with_taxonomy21_title) { translated(meeting_with_taxonomy21.title) }
    let(:resource_with_taxonomy22_title) { translated(meeting_with_taxonomy22.title) }
  end

  context "when filtering by origin" do
    let!(:official_meeting) { create(:meeting, :official, component:) }
    let!(:participant_meeting) { create(:meeting, :not_official, component:) }

    before { visit_component_admin }

    context "when filtering participants" do
      context "when no official meeting is present" do
        it_behaves_like "a filtered collection", options: "Origin", filter: "Participant" do
          let(:in_filter) { translated(participant_meeting.title) }
          let(:not_in_filter) { translated(official_meeting.title) }
        end
      end
    end

    context "when filtering official" do
      context "when no participant meeting is present" do
        it_behaves_like "a filtered collection", options: "Origin", filter: "Official" do
          let(:in_filter) { translated(official_meeting.title) }
          let(:not_in_filter) { translated(participant_meeting.title) }
        end
      end
    end
  end

  context "when filtering by Date" do
    let!(:past_meeting) { create(:meeting, :past, component:) }
    let!(:future_meeting) { create(:meeting, :upcoming, component:) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Date", filter: "Upcoming" do
      let(:in_filter) { translated(future_meeting.title) }
      let(:not_in_filter) { translated(past_meeting.title) }
    end

    it_behaves_like "a filtered collection", options: "Date", filter: "Past" do
      let(:in_filter) { translated(past_meeting.title) }
      let(:not_in_filter) { translated(future_meeting.title) }
    end
  end

  context "when searching by ID or title" do
    let!(:meeting1) { create(:meeting, component:) }
    let!(:meeting2) { create(:meeting, component:) }
    let!(:meeting1_title) { translated(meeting1.title) }
    let!(:meeting2_title) { translated(meeting2.title) }

    before { visit_component_admin }

    it "can be searched by ID" do
      search_by_text(meeting1.id)

      expect(page).to have_content(meeting1_title)
    end

    it "can be searched by title" do
      search_by_text(meeting2_title)

      expect(page).to have_content(meeting2_title)
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:meeting, 50, component:) }
  end
end
