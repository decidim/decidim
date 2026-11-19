# frozen_string_literal: true

require "spec_helper"

describe Decidim::StatsParticipantsCount do
  subject { described_class.new(participatory_space).query }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :published, organization:) }
  let(:component) { create(:meeting_component, :published, participatory_space:) }

  describe "meeting attendees" do
    let!(:closed_meeting) { create(:meeting, :published, :closed, attendees_count: 12, component:) }
    let!(:another_closed_meeting) { create(:meeting, :published, :closed, attendees_count: 8, component:) }

    it "adds the attendees of closed meetings to the participants" do
      expect(subject).to eq(20)
    end

    it "adds the attendees on top of the unique registered participants" do
      create(:registration, meeting: closed_meeting)
      create(:registration, meeting: another_closed_meeting)

      expect(subject).to eq(22)
    end

    it "does not count twice the validated registrations included in the attendees" do
      create_list(:registration, 3, meeting: closed_meeting, validated_at: Time.current)

      expect(subject).to eq(20)
    end

    it "does not subtract more validated registrations than attendees" do
      create_list(:registration, 10, meeting: another_closed_meeting, validated_at: Time.current)

      expect(subject).to eq(22)
    end

    context "when the meetings should not disclose their attendees" do
      let(:unpublished_component) { create(:meeting_component, :unpublished, participatory_space:) }
      let(:other_space_component) { create(:meeting_component, :published, organization:) }

      before do
        create(:meeting, :published, attendees_count: 5, component:)
        create(:meeting, :closed, attendees_count: 5, component:)
        create(:meeting, :published, :closed, closing_visible: false, attendees_count: 5, component:)
        create(:meeting, :published, :closed, private_meeting: true, transparent: false, attendees_count: 5, component:)
        create(:meeting, :published, :closed, attendees_count: 5, component: unpublished_component)
        create(:meeting, :published, :closed, attendees_count: 5, component: other_space_component)
        hidden_meeting = create(:meeting, :published, :closed, attendees_count: 5, component:)
        create(:moderation, reportable: hidden_meeting, hidden_at: 1.day.ago)
      end

      it "does not add their attendees" do
        expect(subject).to eq(20)
      end
    end

    context "when the meeting is private but transparent" do
      before do
        create(:meeting, :published, :closed, private_meeting: true, transparent: true, attendees_count: 5, component:)
      end

      it "adds its attendees" do
        expect(subject).to eq(25)
      end
    end

    context "when counting through a participatory process" do
      subject { Decidim::ParticipatoryProcesses::ParticipatoryProcessesStatsParticipantsCount.for(participatory_space) }

      before do
        unpublished_component = create(:meeting_component, :unpublished, participatory_space:)
        create(:meeting, :published, :closed, attendees_count: 5, component: unpublished_component)
      end

      it "adds the attendees of the published components only" do
        expect(subject).to eq(20)
      end
    end
  end
end
