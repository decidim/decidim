# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CloseMeetingForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:meeting) { create(:meeting, component:) }
    let(:component) { create(:meeting_component) }
    let(:attendees_count) { 5 }
    let(:attributes) do
      {
        attendees_count:,
        closing_report:
      }
    end
    let(:closing_report) { "It went great" }
    let(:context) do
      {
        current_organization: meeting.organization,
        current_component: component,
        current_participatory_space: component.participatory_space
      }
    end

    it { is_expected.to be_valid }

    describe "closed_at" do
      it "is set by default" do
        expect(subject.closed_at).to be_kind_of(Time)
      end
    end

    describe "when closing_report is missing" do
      let(:closing_report) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when attendees_count is missing" do
      let(:attendees_count) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when attendees_count is greater than 999" do
      let(:attendees_count) { 10_000 }

      it { is_expected.not_to be_valid }
    end

    describe "when attendees_count is less than 0" do
      let(:attendees_count) { -10 }

      it { is_expected.not_to be_valid }
    end

    describe "when attendees_count is invalid" do
      let(:attendees_count) { "a" }

      # The value is cast to the correct type so "a" becomes 0 which is valid.
      it { is_expected.to be_valid }
    end

    describe "map_model" do
      subject { described_class.from_model(meeting).with_context(context) }

      let(:proposal_component) { create(:proposal_component, participatory_space: component.participatory_space) }
      let(:proposals) { create_list(:proposal, 3, component: proposal_component) }

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
