require "spec_helper"

describe Decidim::Meetings::Admin::CloseMeeting do
  let(:meeting) { create :meeting }
  let(:form) do
    double(
      :invalid? => invalid,
      closing_report: { en: "Great meeting" },
      attendees_count: 10,
      contributions_count: 15,
      attending_organizations: "Some organization",
      closed_at: Time.current,
      proposal_ids: proposal_ids
    )
  end
  let(:proposal_feature) do
    create(:feature, manifest_name: :proposals, participatory_process: meeting.feature.participatory_process)
  end
  let(:invalid) { false }
  let(:proposals) do
    create_list(
      :proposal,
      3,
      feature: proposal_feature
    )
  end
  let(:proposal_ids) { proposals.map(&:id) }

  subject { described_class.new(form, meeting) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "doesn't perform any other action" do
      expect(meeting).not_to receive(:update_attributes!)
      expect(Decidim::ResourceLink).not_to receive(:create!)

      subject.call
    end
  end

  context "when everything is ok" do
    it "updates the meeting with the closing details" do
      subject.call

      expect(meeting).to be_closed
    end

    context "when previous proposals had been linked" do
      let(:previous_proposals) { create_list(:proposal, 3, feature: proposal_feature) }

      before do
        meeting.link_resources(previous_proposals, "proposals_from_meeting")
      end

      it "unlinks them" do
        expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).to match_array(previous_proposals)

        subject.call

        expect(meeting.linked_resources(:proposals, "proposals_from_meeting").length).to eq(3)
        expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).not_to match_array(previous_proposals)
        expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).to match_array(proposals)
      end
    end

    it "links to the given proposals" do
      subject.call

      expect(meeting.linked_resources(:proposals, "proposals_from_meeting").length).to eq(3)
      expect(meeting.linked_resources(:proposals, "proposals_from_meeting")).to match_array(proposals)
    end
  end
end
