# frozen_string_literal: true

require "spec_helper"

describe Decidim::Results::Admin::UpdateResult do
  let(:result) { create :result }
  let(:organization) { result.feature.organization }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: result.feature.participatory_process }
  let(:participatory_process) { result.feature.participatory_process }
  let(:meeting_feature) do
    create(:feature, manifest_name: :meetings, participatory_process: participatory_process)
  end
  let(:meeting) do
    create(
      :meeting,
      feature: meeting_feature
    )
  end
  let(:proposal_feature) do
    create(:feature, manifest_name: :proposals, participatory_process: participatory_process)
  end
  let(:proposals) do
    create_list(
      :proposal,
      3,
      feature: proposal_feature
    )
  end
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      proposal_ids: proposals.map(&:id),
      scope: scope,
      category: category
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, result) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "updates the result" do
      subject.call
      expect(translated(result.title)).to eq "title"
    end

    it "sets the scope" do
      subject.call
      expect(result.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(result.category).to eq category
    end

    it "links proposals" do
      subject.call
      linked_proposals = result.linked_resources(:proposals, "included_proposals")
      expect(linked_proposals).to match_array(proposals)
    end

    it "links meetings" do
      proposals.each do |proposal|
        proposal.link_resources([meeting], "proposals_from_meeting")
      end

      subject.call
      linked_meetings = result.linked_resources(:meetings, "meetings_through_proposals")

      expect(linked_meetings).to eq [meeting]
    end
  end
end
