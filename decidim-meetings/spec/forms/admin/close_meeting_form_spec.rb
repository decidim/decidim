# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CloseMeetingForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:meeting) { create(:meeting) }
    let(:attributes) do
      {
        closing_report: closing_report,
        attendees_count: attendees_count,
        contributions_count: contributions_count,
        attending_organizations: attending_organizations
      }
    end
    let(:closing_report) { { en: "It went great", ca: "Ha anat molt bé", es: "Ha ido muy bien" } }
    let(:attendees_count) { 10 }
    let(:contributions_count) { 20 }
    let(:attending_organizations) { "Foo, bar & baz" }
    let(:context) { { current_organization: meeting.organization } }

    it { is_expected.to be_valid }

    describe "closed_at" do
      it "is set by default" do
        expect(subject.closed_at).to be_kind_of(Time)
      end
    end

    describe "when closing_report is missing" do
      let(:closing_report) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when attendees_count is missing" do
      let(:attendees_count) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when attendees_count is invalid" do
      let(:attendees_count) { "a" }

      it { is_expected.not_to be_valid }
    end

    describe "when contributions_count is missing" do
      let(:contributions_count) { nil }

      it { is_expected.to be_valid }
    end

    describe "when contributions_count is invalid" do
      let(:contributions_count) { "a" }

      it { is_expected.not_to be_valid }
    end

    describe "map_model" do
      subject { described_class.from_model(meeting) }

      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: meeting.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 3, component: proposal_component) }
      let(:meeting) { create(:meeting) }

      before do
        meeting.link_resources(proposals, "proposals_from_meeting")
      end

      it "sets the proposals scope" do
        expect(subject.proposals).to match_array(proposals)
      end

      context "when the meeting is already linked to some proposals" do
        it "sets the proposal_ids" do
          expect(subject.proposal_ids).to match_array(proposals.map(&:id))
        end
      end
    end
  end
end
