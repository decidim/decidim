require "spec_helper"

describe Decidim::Results::Admin::CreateResult do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, manifest_name: :results, participatory_process: participatory_process }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: participatory_process }
  let(:meeting_feature) do
    create(:feature, manifest_name: :meetings, participatory_process: participatory_process)
  end
  let(:meetings) do
    create_list(
      :meeting,
      3,
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
      :invalid? => invalid,
      title: {en: "title"},
      description: {en: "description"},
      short_description: {en: "short_description"},
      meeting_ids: meetings.map(&:id),
      proposal_ids: proposals.map(&:id),
      scope: scope,
      category: category,
      current_feature: current_feature
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:result) { Decidim::Results::Result.last }

    it "creates the result" do
      expect { subject.call }.to change { Decidim::Results::Result.count }.by(1)
    end

    it "sets the scope" do
      subject.call
      expect(result.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(result.category).to eq category
    end

    it "sets the feature" do
      subject.call
      expect(result.feature).to eq current_feature
    end

    it "links proposals" do
      subject.call
      linked_proposals = result.linked_resources(:proposals, "proposals_from_result")
      expect(linked_proposals).to match_array(proposals)
    end

    it "links meetings" do
      subject.call
      linked_meetings = result.linked_resources(:meetings, "meetings_from_result")
      expect(linked_meetings).to match_array(meetings)
    end
  end
end
